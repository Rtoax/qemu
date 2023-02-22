Qemu libcareplus
================

# 步骤

## 一个修改"balloon"的示例

1. 分别执行脚本
	`compile.sh: config -> diff -> make`
2. 修改虚拟机的 qemu-kvm 模拟器
	1. `sudo virsh edit fedora`
		`<emulator>/usr/libexec/qemu-kvm-custom</emulator>`
	2. 创建符号链接
		`/usr/libexec/qemu-kvm-custom -> /home/rongtao/Git/qemu/build/qemu-system-x86_64`
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
