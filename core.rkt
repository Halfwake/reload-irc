#lang racket/base

(require racket/async-channel
         racket/match
         racket/list
         racket/string
         irc
         reloadable)

(provide run-reload-bot)

(define handle-private-message
  (reloadable-entry-point->procedure
   (make-reloadable-entry-point 'handle-private-message "handler.rkt")))

(define (run-reload-bot name server channel)
  (define-values (connection ready-event)
    (irc-connect server 6667 name name name))
  (void (sync ready-event))
  
  (irc-join-channel connection channel)
  (define incoming (irc-connection-incoming connection))
  
  (let loop ()
    (define message (async-channel-get incoming))
    (match message
      [(irc-message _ "PRIVMSG" _ _)
       (handle-private-message name message connection channel)]
      [else (void)])
    (loop)))

(module+ main
  (run-reload-bot (begin (displayln "Name: ") (read-line))
                  (begin (displayln "Server: ") (read-line))
                  (begin (displayln "Channel: ") (read-line))))
