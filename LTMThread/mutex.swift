//
//  mutex.swift
//  LTMThread

import Foundation

public class LTMMutex {
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    
    public init() {
        var attr: pthread_mutexattr_t = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        
        let err = pthread_mutex_init(&self.mutex, &attr)
        pthread_mutexattr_destroy(&attr)
        
        switch err {
        case 0:
            // Success
            break
            
        case EAGAIN:
            fatalError("Création d'un autre mutex")
            
        case EINVAL:
            fatalError("Attributs invalides")
            
        case ENOMEM:
            fatalError("Pas de mémoire")
            
        default:
            fatalError("Erreur inconnue \(err)")
        }
    }
    
    private final func lock() {
        let ret = pthread_mutex_lock(&self.mutex)
        switch ret {
        case 0:
            // Success
            break
            
        case EDEADLK:
            fatalError("Deadlock")
            
        case EINVAL:
            fatalError("Mutex invalide")
            
        default:
            fatalError("Erreur non spécifiée \(ret)")
        }
    }
    
    private final func unlock() {
        let ret = pthread_mutex_unlock(&self.mutex)
        switch ret {
        case 0:
            // Success
            break
            
        case EPERM:
            fatalError("Le thread ne peut porter ce mutex")
            
        case EINVAL:
            fatalError("Mutex invalide")
            
        default:
            fatalError("Erreur inconnue \(ret)")
        }
    }
    
    deinit {
        assert(pthread_mutex_trylock(&self.mutex) == 0 && pthread_mutex_unlock(&self.mutex) == 0, "deinitialization of a locked mutex results in undefined behavior!")
        pthread_mutex_destroy(&self.mutex)
    }
    
    @discardableResult public final func locked<T>(_ block: () throws -> (T)) throws -> T {
        return try self.tryLocked(block)
    }
    
    @discardableResult public final func locked<T>(_ block: () -> (T)) -> T {
        return try! self.tryLocked(block)
    }
    
    /** Execute the given block while holding a lock to this mutex. */
    @discardableResult public final func tryLocked<T>(_ block: () throws -> (T)) throws -> T {
        self.lock()
        
        defer {
            self.unlock()
        }
        let ret: T = try block()
        return ret
    }
}

// Use as follows:
var counter = 0
let counterMutex = LTMMutex()

func incrementCounter() -> Int{
    return counterMutex.locked {
        let oldValue = counter
        counter += 1
        return oldValue
    }
}
