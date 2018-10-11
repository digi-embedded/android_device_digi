add_lunch_combo ccimx6sbc-eng
add_lunch_combo ccimx6sbc-user

# Copy local configuration makefile
VS_ABSPATH="$(cd $(dirname "${BASH_SOURCE}") && pwd)"
VS_LOCALCONF_DESTDIR="$(gettop)"
VS_LOCALCONF_TEMPLATE="localconf.mk_template"

if [ -d "${VS_LOCALCONF_DESTDIR}" ]; then
	if [ ! -f "${VS_LOCALCONF_DESTDIR}/${VS_LOCALCONF_TEMPLATE%_template}" ]; then
		echo "### File ${VS_LOCALCONF_TEMPLATE%_template} created in ${VS_LOCALCONF_DESTDIR} with default values. Make sure you have the right configuration setup"
		install -m 0644 "${VS_ABSPATH}/build/${VS_LOCALCONF_TEMPLATE}" "${VS_LOCALCONF_DESTDIR}/${VS_LOCALCONF_TEMPLATE%_template}"
	fi
fi
unset VS_ABSPATH VS_LOCALCONF_DESTDIR VS_LOCALCONF_TEMPLATE
