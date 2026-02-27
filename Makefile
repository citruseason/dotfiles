.PHONY: all personal work list help

all:
	./bin/dotfiles --all

personal:
	./bin/dotfiles --all personal

work:
	./bin/dotfiles --all work

list:
	./bin/dotfiles --list

help:
	./bin/dotfiles --help
