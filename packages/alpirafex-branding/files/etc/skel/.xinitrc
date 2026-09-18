#!/bin/sh

if command -v dbus-run-session >/dev/null 2>&1; then
	exec dbus-run-session -- i3
fi

exec i3
