.PHONY: personal work ubuntu wsl

personal:
	ansible-playbook site.yml -i inventory/personal.yml --ask-become-pass

work:
	ansible-playbook site.yml -i inventory/work.yml --ask-become-pass

ubuntu:
	ansible-playbook site.yml -i inventory/ubuntu.yml --ask-become-pass

wsl:
	ansible-playbook site.yml -i inventory/wsl.yml --ask-become-pass
