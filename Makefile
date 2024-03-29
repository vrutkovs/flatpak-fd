all: prepare-repo install-deps build clean-cache update-repo

prepare-repo:
	[[ -d repo ]] || ostree init --mode=archive-z2 --repo=repo
	[[ -d repo/refs/remotes ]] || mkdir -p repo/refs/remotes && touch repo/refs/remotes/.gitkeep

install-deps:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install -y flathub \
		org.freedesktop.Platform/x86_64/18.08 \
		org.freedesktop.Sdk/x86_64/18.08 \
		org.freedesktop.Sdk.Extension.rust-stable/x86_64/18.08

build:
	flatpak-builder --force-clean --ccache --require-changes --repo=repo \
		--subject="Nightly build of fd, `date`" \
		--allow-missing-runtimes \
		${EXPORT_ARGS} app com.github.sharkdp.FD.yaml

clean-cache:
	rm -rf .flatpak-builder/build

update-repo:
	flatpak build-update-repo --prune --prune-depth=20 --generate-static-deltas repo
	echo 'gpg-verify-summary=false' >> repo/config
	rm -rf repo/.lock
