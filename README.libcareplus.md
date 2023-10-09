Qemu libcareplus
================

# 源码仓库

- CESTC: [libcareplus](https://code.cestc.cn/os/libcareplus.git)
	- openEuler 在 gitee 上也有开源仓库，我们的仓库作了很多优化和修改；
- qemu
	- [github](https://github.com/qemu/qemu.git)
	- [cestc gitlab](https://code.cestc.cn/os/src/qemu/-/tree/libcareplus-v8.1.0) fork from github
		- 里面存放了一些脚本和说明，如此分支的一次提交;
	- [gitlab](https://gitlab.com/qemu-project/qemu.git)
- ostools
	- [cestc](https://code.cestc.cn/rongtao/ostools.git)
	- 封装了一些 libcareplus 和 qemu 编译的脚本，更易用，非必须


# 步骤

记录qemu热补丁流程
==================

> 最新

1. 编译补丁文件； 由于我已经编译好了，此处不做赘述;
2. 默认情况下，VM 使用的qemu为特定的，是我们使用源代码编译出的qemu；
	我这里用虚拟机 Feodra-40 为例
	我已经将 VM 的 qemu 修改为 `/usr/bin/qemu/lpmake/usr/bin/qemu-system-x86_64`
	我使用的 qemu 版本为 `qemu v8.1.0-1354-gb076559bf21b-dirty` 上游最新的
	此时我的 fedora 虚拟机正在运行中...
3. 此时虚拟机正常运行;
	我们在虚拟机内部运行一个进程，循环打印
	同时我们查看虚拟机的内存使用情况，并使用 tail 命令查看虚拟机日志；
		sudo virsh dommemstat Fedora-40
	可见，每次执行上述命令，qemu 日志都打印
		info: # virsh dommemstat called #
4. 我们先查看补丁内容
	这个补丁是修改了这条日志
5. 应用补丁
	$ sudo libcare-ctl patch -p 1513975 1.upatch
6. 查看补丁
	$ sudo libcare-ctl info -p 1513975
7. 验证补丁
	执行命令
		sudo virsh dommemstat Fedora-40
	qemu日志变为补丁后内容
		info: # virsh dommemstat called PATCHED #

#此时虚拟机运行正常#

8. 卸载补丁
	$ sudo libcare-ctl unpatch -p 1513975 -i 1
9. 再次查看
	$ sudo libcare-ctl info -p 1513975
10. 验证补丁卸载
	执行命令
		$ sudo virsh dommemstat Fedora-40
	此时日志内容被恢复
		info: # virsh dommemstat called #

#此时虚拟机运行正常#

一个修改"balloon"的示例
=======================

> 老版本

1. 分别执行脚本
	`compile.sh: config -> diff -> make`
2. 修改虚拟机的 qemu-kvm 模拟器
	1. `sudo virsh edit fedora`
		`<emulator>/usr/libexec/qemu-kvm-custom</emulator>`
	2. 创建符号链接
		`/usr/libexec/qemu-kvm-custom -> /home/rongtao/Git/qemu/build/qemu-system-x86_64`
	3. 如果存在修改后“Permission Deny”，那么需要更换目录，如
		`cp -a build/ /usr/bin/qemu/`
		然后将 emulator 改为 `/usr/bin/qemu/qemu-kvm-custom`
3. 启动虚拟机
	`sudo virsh start fedora`
4. 清空并监控日志
	1. 清空: `sudo sh -c 'echo > /var/log/libvirt/qemu/fedora.log'`
	2. 监控日志: `sudo watch -n1 cat /var/log/libvirt/qemu/fedora.log`
5. 查看内存 balloon 信息
	`sudo virsh dommemstat fedora`
6. 打补丁
	`sudo libcare-ctl patch -p $(pidof qemu-kvm-custom) 3.upatch`
7. 再次执行(5)，会看到(4.2)监控的日志变成了
```
	info: # virsh dommemstat called #
	info: # virsh dommemstat, patched by libcareplus #
```
8. 查看补丁信息
	`$ sudo libcare-ctl info -p $(pidof qemu-kvm-custom)`
9. 删除补丁
	`sudo libcare-ctl unpatch -p $(pidof qemu-kvm-custom) -i 1`
10. 再次执行(5)，并查看(4.2)监控的日志信息为
```
info: # virsh dommemstat called #
info: # virsh dommemstat, patched by libcareplus #
info: # virsh dommemstat called #
```


# 链接

- [5.Qemu-6.1.0单热补丁示例: 文末视频](https://wiki.cestc.cn/pages/viewpage.action?pageId=111065442)
