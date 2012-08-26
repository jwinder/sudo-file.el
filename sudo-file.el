;;; sudo-file.el
;;
;; Other 'sudo' packages didn't work well for me, so here's a simple one.
;;
;; Simple functions for reading/writing protected files on a linux operating system.
;; Not saying this is isn't potentially dangerous.
;; It might mess up your file's permissions.
;; Use at your own risk.
;; Don't worry, nothing malicious is done with your password here.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA

(defun sudo-find-file (file)
  "Temporarily changes the file to readable while opening it in a buffer. Returns the original permissions afterwards."
  (interactive "F(sudo) Find file: ")
  (let ((password (sudo-get-password))
        (modes (sudo-get-file-modes file)))
    (sudo-set-file-modes file "o+r" password)
    (find-file file)
    (rename-buffer (concat (buffer-name) " (sudo)"))
    (sudo-set-file-modes file modes password)
    (if buffer-read-only
        (toggle-read-only))))

(defun sudo-save-buffer ()
  "Temporarily changes to writable while saving it. Returns the original permissions afterwards."
  (interactive)
    (let ((password (sudo-get-password))
          (modes (sudo-get-file-modes buffer-file-name)))
    (sudo-set-file-modes buffer-file-name "o+w" password)
    (save-buffer)
    (sudo-set-file-modes buffer-file-name modes password)))

(defun sudo-get-file-modes (file)
  (format "%o" (file-modes file)))

(defun sudo-set-file-modes (file modes password)
  (shell-command-to-string (format "echo %s | sudo -k -S chmod %s %s; sudo -K" password modes file))
  (sleep-for 0.5))

(defun sudo-get-password ()
  (read-passwd "Sudo password: "))

(provide 'sudo-file)
