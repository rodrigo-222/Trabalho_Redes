from scapy.all import sniff

def show(pkt):
    pkt.show()

sniff(count=5, timeout=10, prn=show)