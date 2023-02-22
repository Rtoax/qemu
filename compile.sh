#!/bin/bash


TESTING="\033[1;35m Testing \033[m"
OK="\033[1;32m OK \033[m"
NOTOK="\033[1;31m NotOK \033[m"

BUILDDIR=build

PATCH_0001_SOFTMMU_BALLOON=${BUILDDIR}/0001.softmmu-balloon.patch


build_with_gcc()
{
	./ostools/qemu/compile.sh \
		-bc \
		--rootdir $PWD \
		--compiler gcc \
		--disable-lto

	sed "s/ command = gcc / command = libcare-cc /g" -i ${BUILDDIR}/build.ninja
	sed "s/ command = c++ / command = libcare-cc /g" -i ${BUILDDIR}/build.ninja
}

get_all_patches()
{
	echo -e " $PATCH_0001_SOFTMMU_BALLOON $OK, add \`info_report()'"
	diff -up softmmu/balloon.c patches/softmmu-balloon.c > $PATCH_0001_SOFTMMU_BALLOON
}

compile_with_gcc()
{
	[[ ! -e $PATCH_0001_SOFTMMU_BALLOON ]] && \
		echo "$PATCH_0001_SOFTMMU_BALLOON not exist" && \
		exit 1

	# libcare-patch-make -C ./build/ -V -vvvvvvv --clean -j 1 -i 1 $PATCH_0001_SOFTMMU_BALLOON
	# --make-arg='-vvvv' \
	# --make-arg='-D -V -vvvv' \
	# --make-arg='--clean' \
	./ostools/qemu/compile.sh \
		-bm \
		--rootdir $PWD \
		--compiler gcc \
		--jobs 8 \
		--make-noerr \
		--make libcare-patch-make \
			--make-arg='-B' \
			--make-arg='-i 1' \
			--make-arg="$(realpath $PATCH_0001_SOFTMMU_BALLOON)"
}

clean_all()
{
	rm *.upatch
}

# __MAIN__
case $1 in
config)
	build_with_gcc
	;;
diff)
	get_all_patches
	;;
make)
	compile_with_gcc
	;;
clean)
	clean_all
	;;
*)
	cat <<-END
Usage:

 config       - configure
 diff         - apply diff
 make         - make

 clean        - clean everything
END
	;;
esac

