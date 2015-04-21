import structs/LinkedList
import threading/Thread
import threading/native/ConditionUnix

ThreadJob: class {
	_body: Func
	init: func (=_body)
	execute: virtual func { this _body() }
}

SynchronizedThreadJob: class extends ThreadJob {
	_finishedCondition := ConditionUnix new()
	_mutex := Mutex new()
	_finished := false
	finished ::= this _finished
	init: func (body: Func) { super(body) }
	free: override func {
		this _mutex destroy()
		this _finishedCondition free()
		super()
	}
	execute: override func {
		super()
		this _mutex lock()
		this _finished = true
		this _mutex unlock()
		this _finishedCondition broadcast()
	}
	wait: func {
		this _mutex lock()
		if(!this _finished)
			this _finishedCondition wait(this _mutex)
		this _mutex unlock()
	}
}

ThreadPool: class {
	_jobs: LinkedList<ThreadJob>
	_threads: Thread[]
	_mutex: Mutex
	_newJobCondition: ConditionUnix
	_allFinishedCondition: ConditionUnix
	_activeJobs: Int
	_threadCount: Int
	threadCount ::= this _threadCount

	init: func (threadCount := 4) {
		this _threadCount = threadCount
		this _threads = Thread[threadCount] new()
		this _jobs = LinkedList<ThreadJob> new()
		this _mutex = Mutex new()
		this _newJobCondition = ConditionUnix new()
		this _allFinishedCondition = ConditionUnix new()

		for(i in 0..threadCount) {
			this _threads[i] = Thread new(|| threadLoop())
			this _threads[i] start()
		}
	}
	threadLoop: func {
		while(true) {
			this _mutex lock()
			if(this _jobs getSize() > 0) {
				job := this _jobs first()
				this _jobs removeAt(0)
				this _mutex unlock()
				job execute()
				this _mutex lock()
				this _activeJobs -= 1
				if(this _activeJobs == 0)
					this _allFinishedCondition broadcast()
			}
			else
				this _newJobCondition wait(this _mutex)
			this _mutex unlock()
		}
	}
	_add: func (job: ThreadJob) {
		this _mutex lock()
		this _jobs add(job)
		this _activeJobs += 1
		this _newJobCondition broadcast()
		this _mutex unlock()
	}
	addSynchronized: func (body: Func) -> SynchronizedThreadJob {
		job := SynchronizedThreadJob new(body)
		this _add(job)
		job
	}
	add: func (body: Func) { this _add(ThreadJob new(body)) }
	waitAll: func {
		this _mutex lock()
		if (this _activeJobs > 0)
			this _allFinishedCondition wait(this _mutex)
		this _mutex unlock()
	}


}
