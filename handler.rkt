#lang racket/base

(require irc
         racket/match
         racket/list
         racket/string
         racket/function
         racket/async-channel)

(provide handle-private-message)

(define (text-normalize text)
  (string-trim (string-downcase (string-trim text (list->string (list #\u0001))))))

(define custom-message-channel (make-async-channel))

(define (send-custom-message text)
  (async-channel-put custom-message-channel text))

(define (handle-private-message bot-name message connection channel)
  (match-define (irc-message prefix "PRIVMSG" (list sent-to text _ ...) _) message)
  (define name (first (regexp-match #rx"[^!]+" prefix)))
  (define return-to
    (if (equal? sent-to bot-name)
        name
        channel))
  (match (async-channel-try-get custom-message-channel)
    [(and (? string?) text) (irc-send-message connection channel text)]
    [#f (void)])
  (define salute-pattern (string-append "action salutes " + name))
  (cond [(equal? (text-normalize-text)
                 (string-append "action salutes " + name))
         (irc-send-message connection return-to
                       "ビシッ! ∠(^ー^)")]
        [else (void)]))
