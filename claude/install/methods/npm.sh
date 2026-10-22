# Global npm package. npm installs into the active Node.js version, so an
# install under another version (e.g. after a mise upgrade) is not detected
# and is not on PATH.

CIM_NPM_PACKAGE="@anthropic-ai/claude-code"

cim_npm_command() { echo npm; }

cim_npm_installed() { command_exists npm && npm ls -g "$CIM_NPM_PACKAGE" >/dev/null 2>&1; }

# The global prefix shows which Node.js install holds the package
cim_npm_detail() { npm prefix -g 2>/dev/null; }

# The official docs say to upgrade with install @latest, not `npm update -g`
cim_npm_install() { npm install -g "$CIM_NPM_PACKAGE@latest"; }

cim_npm_update() { cim_npm_install; }

cim_npm_uninstall() { npm uninstall -g "$CIM_NPM_PACKAGE"; }
