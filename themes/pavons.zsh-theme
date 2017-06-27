# Based on the great ys theme (https://github.com/oskarkrawczyk/honukai-iterm-zsh)

# References
# https://github.com/oskarkrawczyk/honukai-iterm-zsh/pull/13/commits/b9cb897321c046ce4570d8ced967c306331f22be
# https://github.com/bhilburn/powerlevel9k/blob/master/powerlevel9k.zsh-theme

# Machine name.
function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || echo $HOST
}

function print_box_name {
	if [[ -n $PROMPT_PRINT_BOX_NAME ]]; then
		echo -n "%{$fg[white]%}at "
		echo -n "%{$fg[green]%}$(box_name) "
	fi
}

# Directory info.
local current_dir='${PWD/#$HOME/~}'

# VCS
YS_VCS_PROMPT_PREFIX1=" %{$fg[white]%}on%{$reset_color%} "
YS_VCS_PROMPT_PREFIX2=":%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%}"
YS_VCS_PROMPT_DIRTY=" %{$fg[red]%}✖︎"
YS_VCS_PROMPT_CLEAN=" %{$fg[green]%}●"

# Git info.
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}git${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# HG info
local hg_info='$(ys_hg_prompt_info)'
ys_hg_prompt_info() {
	# make sure this is a hg dir
	if [ -d '.hg' ]; then
		echo -n "${YS_VCS_PROMPT_PREFIX1}hg${YS_VCS_PROMPT_PREFIX2}"
		echo -n $(hg branch 2>/dev/null)
		if [ -n "$(hg status 2>/dev/null)" ]; then
			echo -n "$YS_VCS_PROMPT_DIRTY"
		else
			echo -n "$YS_VCS_PROMPT_CLEAN"
		fi
		echo -n "$YS_VCS_PROMPT_SUFFIX"
	fi
}


local venv_info='$(prompt_venv)'
prompt_venv() {
	local version=""

	# Virtualenv
	local virtualenv_path="$VIRTUAL_ENV"
	if [[ -n "$virtualenv_path" && "$VIRTUAL_ENV_DISABLE_PROMPT" != true ]]; then
		version=$virtualenv_path
	fi

	# Pyenv-virtualenv
	local pyenv_version="$(pyenv version 2>/dev/null)"
	pyenv_version="${pyenv_version%% *}"
	if [[ -n "$pyenv_version" && "$pyenv_version" != "system" ]]; then
		version=$pyenv_version
	fi

	# Swift
	# local swift_version=$(swift --version 2>/dev/null | grep -o -E "[0-9.]+" | head -n 1)
	# if [ ! -z "${swift_version}" ]; then 
	# 	version=$swift_version
	# fi

	if [ ! -z "${version}" ]; then
		echo -n "(%{$fg[blue]%}${version}%{$reset_color%}) "
	fi
}

# Prompt format: \n # USER at MACHINE in DIRECTORY on git:BRANCH STATE [TIME] \n $
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
${venv_info}\
%{$fg[cyan]%}%n \
$(print_box_name)\
%{$fg[white]%}in \
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%}\
${hg_info}\
${git_info} \
%{$fg[white]%}[%*]
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%} "

if [[ "$USER" == "root" ]]; then
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
${venv_info}\
%{$bg[yellow]%}%{$fg[cyan]%}%n%{$reset_color%} \
$(print_box_name)\
%{$fg[white]%}in \
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%}\
${hg_info}\
${git_info} \
%{$fg[white]%}[%*]
%{$terminfo[bold]$fg[red]%}→ %{$reset_color%} "
fi
