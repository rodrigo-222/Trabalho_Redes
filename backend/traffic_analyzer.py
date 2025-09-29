from scapy.all import sniff
from collections import defaultdict
import time


WINDOW = 5
traffic_data = defaultdict(lambda: {'in':0, 'out':0, 'protocols':defaultdict(int)})
start = time.time()
SERVER_IP = "192.168.0.12"

def process_packet(pkt):
    """Processa cada pacote capturado."""

    global start, traffic_data, SERVER_IP
    now = time.time()

    if pkt.haslayer('IP'):
        src = pkt['IP'].src
        dst = pkt['IP'].dst
        size = len(pkt)
        if dst == SERVER_IP:
            traffic_data[src]['in'] += size
            proto = pkt['IP'].proto
            traffic_data[src]['protocols'][proto] += size
        elif src == SERVER_IP:
            traffic_data[dst]['out'] += size
            proto = pkt['IP'].proto
            traffic_data[dst]['protocols'][proto] += size

    if now - start >= WINDOW:
        print(f"\n--- Dados da janela de {WINDOW} segundos ---")
        if traffic_data:
            print(traffic_data)
            for ip, data in traffic_data.items():
                print(f"IP: {ip}, In: {data['in']}, Out: {data['out']}, Protocols: {dict(data['protocols'])}")

        print("Window reset, data sent to API.")

print("Iniciando captura de pacotes para o servidor...\n")
sniff(prn=process_packet, store=False, filter=f"host {SERVER_IP}")