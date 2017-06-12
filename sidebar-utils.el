;;; sidebar-utils.el --- sidebar-utils

;; Copyright (C) 2017 Sebastien Chapuis

;; Author: Sebastien Chapuis <sebastien@chapu.is>
;; URL: https://github.com/sebastiencs/sidebar.el
;; Keywords: project, sidebar, projectile, file explorer
;; Version: 0.0.1
;; Package-Requires: ((dash "2.13.0") (projectile "0.11.0"))

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Functions needed in files sidebar.el and sidebar-select.el
;;

;;; Code:

(defvar sidebar-width)

(defmacro sidebar-get (var)
  "Get VAR in the current frame."
  (let ((var-name (intern (format "sidebar-%s" var))))
    `(frame-parameter nil ',var-name)))

(defmacro sidebar-set (var val)
  "Set VAR to VAL in the current frame."
  (let ((var-name (intern (format "sidebar-%s" var))))
    `(set-frame-parameter nil ',var-name ,val)))

(defmacro sidebar-set1 (var val)
  "Set VAR to VAL in the current frame.
The difference with `sidebar-set' is that the var parameter is
evaluated.
The var need to be prefixed with 'sidebar-'."
  `(set-frame-parameter nil ,var ,val))

(defun sidebar-gui? ()
  "Return non-nil if we're on a graphic instance."
  (display-graphic-p))

(defun sidebar-goto-line (line &optional force)
  "Go to LINE.
The function checks to not go at the last line (there is no
filename on this line)
if FORCE is non-nil, there is no check."
  (if force
      (forward-line (- line (line-number-at-pos)))
    (let ((max (count-lines (point-min) (point-max))))
      (when (> line max)
	(setq line max))
      (forward-line (- line (line-number-at-pos))))))

(defun sidebar-cons-buffer-name ()
  "Construct the buffer name from 'SIDEBAR' and the frame name.
The return value should be unique for each frame.
On terminals instance, we use the frame parameter `name'
On Graphics ones, the name isn't unique for each frame, so we use
`window-id' that isn't available on terminals instance."
  (let ((name (sidebar-get buffer-name)))
    (if name
	name
      (setq name (concat "*SIDEBAR-" (or (frame-parameter nil 'window-id)
					 (frame-parameter nil 'name))"*"))
      (sidebar-set buffer-name name)
      name)))

;;(ignore-errors (kill-buffer (sidebar-cons-buffer-name)))

(defun sidebar-get-window ()
  "Return the created/existing window displaying the sidebar buffer."
  (let ((sidebar-window (get-buffer-window (sidebar-cons-buffer-name))))
    (unless sidebar-window
      (let ((sidebar-buffer (sidebar-get-buffer)))
	(setq sidebar-window (display-buffer sidebar-buffer (display-buffer-in-side-window sidebar-buffer '((side . left)))))
	(set-window-dedicated-p sidebar-window t)
	(let ((current-width (window-total-width sidebar-window)))
	  (if (> current-width sidebar-width)
	      (window-resize sidebar-window (- sidebar-width current-width) t)
	    (when (< current-width sidebar-width)
	      (window-resize sidebar-window (- current-width sidebar-width) t))))))
    sidebar-window))

(defun sidebar-file-struct (file)
  "Return an association list from FILE.
The parameter FILE is a path.
In this project (sidebar.el) every parameters named 'file' are
object using this structure.
- 'path is the FILE's path
- 'dir is non-nil if FILE is a directory
- 'line is the number line where FILE is printed on the sidebar
- 'opened is non-nil it it's a directory and is expanded.

Example: (('path . \"/tmp/dir1/dir2\") ('dir . t) ('line . 8) ('opened . nil))"
  (list (cons 'path file)
	(cons 'dir (file-directory-p file))
	(cons 'line 0)
	(cons 'opened nil)))

(defun sidebar-get-buffer ()
  "Return the existing/created sidebar buffer for the current frame."
  (get-buffer-create (sidebar-cons-buffer-name)))

(provide 'sidebar-utils)

;;; sidebar-utils.el ends here
