#!/usr/bin/python3
# %%

import matplotlib.pyplot as plt
import numpy as np
from math import floor, ceil
from subprocess import Popen, PIPE
import re, os, sys

script_dir = os.path.dirname(os.path.realpath(__file__))
data_dir = os.path.join(script_dir, "data")
trace_dir = os.path.join(script_dir, "traces")

requested_src_files = ("run.info", "run.info.json", "run.nictrace", "run.ssdtrace")
requested_src_files = ("run.info", "run.nictrace", "run.ssdtrace")
requested_dst_files = ("run.png",)

if len(sys.argv) == 1:
    samples = sorted(os.listdir(data_dir))
elif len(sys.argv) == 2:
    samples = [sys.argv[1]]
else:
    print("Invalid arguments")
    exit(1)

override_dest = True
for sample in samples:
    sample_src_dir = os.path.join(data_dir, sample)
    sample_dst_dir = os.path.join(trace_dir, sample)
    requested_src_files_abs = [os.path.join(sample_src_dir, src_file_name) for src_file_name in requested_src_files]
    requested_dst_files_abs = [os.path.join(sample_dst_dir, dst_file_name) for dst_file_name in requested_dst_files]
    if not override_dest and all([os.path.isfile(file) for file in requested_dst_files_abs]):
        print(f"Skipping <{sample}>, dst exist")
        continue
    if any([not os.path.isfile(file) for file in requested_src_files_abs]):
        print(f"Skipping <{sample}>, src non-exist")
        continue
    print(f"Processing {sample}")

    total_time_override_start = None
    total_time_override_end = None
    start_exe_time, end_time = None, None
    malicious_ips = None

    metrics = {
        "bio_start_time"    : "boot time",
        "start_exe_time"    : "start time",
        "end_time"          : "end time"
    }

    with open(os.path.join(sample_src_dir, "run.info"), "r") as f:
        for line in f:
            for stat, print_str in metrics.items():
                if print_str in line:
                    timestamp = line.split(":")[1].strip()
                    time, unit = [i.strip() for i in timestamp.split()]
                    factor = 1
                    if unit == "ms":
                        factor = 1e3
                    if unit == "us":
                        factor = 1e6
                    if unit == "ns":
                        factor = 1e9
                    time = float(time) / factor
                    exec(f"{stat} = time")

    for metric in metrics.keys():
        exec(f"stat = {metric}")
        print(f"{metric}: {stat}")

    # ==================
    bin_size = 1
    total_figures = 5
    network_figure_start = 2

    malicious_ips = ["x"]
    target = f"{data_dir}/{sample}/run"

    # AvosLocker -- End Behavior: README file appear on Desktop
    # bio_start_time = 10300
    # target = "data/AvosLocker/AvosLocker"

    # BlackBasta
    # bio_start_time = 262.03
    # target = "data/BlackBasta/BlackBasta"

    # Maktub
    # bio_start_time = 381.03
    # target = "data/Maktub/Maktub"

    # CTBLocker -- End Behavior: Popup window
    # bio_start_time, start_exe_time, end_time = 1222.12, 1278.13, 1573.16
    # target = "data/CTBLocker/CTBLocker"

    # DarkSide -- End Behavior: README file appear on Desktop
    # bio_start_time, start_exe_time, end_time = 489.05, 572.06, 715.07
    # total_time_override_start = 50
    # target = "data/DarkSide/DarkSide"

    # HydraCrypt -- End Behavior: README file appear on Desktop
    # bio_start_time, start_exe_time, end_time = 259.03, 1119.11, 1328.13
    # total_time_override_start = 800
    # target = "data/HydraCrypt/HydraCrypt"

    # Mirai -- End Behavior: Nothing
    # bio_start_time, start_exe_time, end_time = 2497.25, 2624.26, 3099.31
    # total_time_override_start = 0
    # target = "data/Mirai/Mirai0"

    # bio_start_time, start_exe_time, end_time = 348.34, 523.52, 936.93
    # total_time_override_start = 0
    # target = "data/Mirai/Mirai1"

    # bio_start_time, start_exe_time, end_time = 631.63, 913.91, 2446.24
    # total_time_override_start = 0
    # malicious_ips = ["158.247.208.230", "185.125.190"]
    # target = "data/Mirai/Mirai2"

    # bio_start_time, start_exe_time, end_time = 361.36, 2615.16, 3530.21
    # total_time_override_start = 2200
    # malicious_ips = ["209.141.45.139"]
    # target = "data/Mirai/Mirai3"

    # bio_start_time, start_exe_time, end_time = 4610.31, 4751.46, 5895.16
    # total_time_override_start = 0
    # malicious_ips = ["209.141.45.139"]
    # target = "data/Mirai/Mirai4"

    # bio_start_time, start_exe_time, end_time = 6376.21, 6509.22, 9457.86
    # total_time_override_start = 0
    # malicious_ips = ["104.168.195.213"]
    # target = "data/Mirai/Mirai5"

    # bio_start_time, start_exe_time, end_time = 536.53, 768.77, 1098.11
    # total_time_override_start = 0
    # malicious_ips = ["xxxx"]
    # target = "data/Mirai/Mirai6"

    # bio_start_time, start_exe_time, end_time = 25127.37, 25195.37, 26848.11
    # total_time_override_start = 0
    # total_time_override_end = 1800
    # malicious_ips = ["104.21.94.9", "172.67.217.207"]
    # target = "data/2e62d6c47c00458da9338c990b095594eceb3994bf96812c329f8326041208e8/run"

    # bio_start_time, start_exe_time, end_time = 420.41, 501.50, 4283.43
    # total_time_override_start = 0
    # total_time_override_end = 1800
    # malicious_ips = ["x"]
    # target = "data/54b20c557d4799a71d05412603a8ce8df29bfd0f2f2528f8053fd5bd6bcd3524/run"

    # bio_start_time, start_exe_time, end_time = 8967.37, 9078.48, 10521.19
    # total_time_override_start = 0
    # total_time_override_end = None
    # malicious_ips = ["x"]
    # target = "data/f3a1576837ed56bcf79ff486aadf36e78d624853e9409ec1823a6f46fd0143ea/run"

    # bio_start_time, start_exe_time, end_time = 456.46, 575.56, 710.70
    # total_time_override_start = 0
    # total_time_override_end = None
    # malicious_ips = ["x"]
    # target = "data/95776f31cbcac08eb3f3e9235d07513a6d7a6bf9f1b7f3d400b2cf0afdb088a7/run"

    # bio_start_time, start_exe_time, end_time = 6547.23, 6860.26, 9262.67
    # total_time_override_start = 0
    # total_time_override_end = None
    # malicious_ips = ["x"]
    # target = "data/e1999a3e5a611312e16bb65bb5a880dfedbab8d4d2c0a5d3ed1ed926a3f63e94/run"

    # bio_start_time, start_exe_time, end_time = 301.911, 602.146, 29700
    # total_time_override_start = 0
    # total_time_override_end = 1800
    # malicious_ips = ["185.165.29.47"]
    # target = "data/4cffb742e51297c5b5d1c6f785c7125bad60259921e60847ec3246cfeb615410/run"

    # bio_start_time, start_exe_time, end_time = 782.856, 873.082, 2873.103
    # total_time_override_start = 0
    # total_time_override_end = 1800
    # malicious_ips = ["x"]
    # target = "data/40b5127c8cf9d6bec4dbeb61ba766a95c7b2d0cafafcb82ede5a3a679a3e3020/run"


    # bio_start_time, start_exe_time, end_time = 17120.406, 17210.644, 19210.676
    # total_time_override_start = 0
    # total_time_override_end = 1800
    # malicious_ips = ["x"]
    # target = "data/6651ce7a82b85ce5e31e367745f754113f9b5ce4dfb0a0b16f4dbcb8dfd7ca1a/run"

    # bio_start_time, start_exe_time, end_time = 27856.21, 27856.21, 32208.14
    # total_time_override_start = 0
    # total_time_override_end = 1800
    # malicious_ips = ["x"]
    # target = "data/normal/run"

    packet_start_time = 0
    # total_time_override = [5246.6, 5246.8]
    # total_time_override = [120, 150]
    # ==================

    ###########
    end_time = start_exe_time + 5 * 60
    ###########

    print(f"Start Execution Time: {(start_exe_time - bio_start_time):.2f} sec")
    print(f"End Execution Time: {(end_time - bio_start_time):.2f} sec")

    trace_dest = os.path.join(trace_dir, sample, "run")
    dest_parent = os.path.abspath(os.path.join(trace_dest, os.path.pardir))

    class BlockIO:
        def __init__(self, timestamp, lpa, ppa, op, hit):
            self.timestamp = float(timestamp) / 500e6 - bio_start_time
            self.lpa = int(lpa) * 4096
            self.ppa = int(ppa) * 4096
            if int(op) == 0:
                self.op = "read"
            elif int(op) == 3:
                self.op = "write"
            else:
                self.op = "na"
            self.hit = hit == "1"

        def __str__(self):
            return f"{self.timestamp} {self.lpa} {self.ppa} {self.op} {self.hit}"

    host = "10.0.2.15"

    class Packet:
        def __init__(self, timestamp, src, src_port, dst, dst_port, pkt_len, protocol):
            self.timestamp = float(timestamp)
            self.src = src
            self.src_port = int(src_port) if src_port.isnumeric() else ""
            self.dst = dst
            self.dst_port = int(dst_port) if src_port.isnumeric() else ""
            self.pkt_len = int(pkt_len)
            self.protocol = protocol

        def __str__(self):
            return f"{self.timestamp} {self.src} {self.src_port} {self.dst} {self.dst_port} {self.pkt_len} {self.protocol}"

    # BlockIO
    bios = []
    pattern = r'\d+ TIME:(\d+) LPA:(\d+) PPA:(\d+) TYPE:(\d+) HIT:(\d+)'
    p = re.compile(pattern)
    with open(f"{target}.ssdtrace") as f:
        for i, raw in enumerate(f):
            result = re.match(pattern, raw)
            if result == None:
                continue
            timestamp, lpa, ppa, op, hit = [result.group(j) for j in range(1, 6)]
            bio = BlockIO(timestamp, lpa, ppa, op, hit)
            if int(timestamp) == 0: # or bio.lpa > 4e10 or bio.ppa > 1e11:
                continue
            # if bio.timestamp < 0 or bio.timestamp > 400 + 7 * 60:
            if bio.timestamp < 0:
                continue
            bios.append(bio)

    bios = sorted(bios, key=lambda x: x.timestamp)
    print(f"Block IO Arr Len: {len(bios)}")

    packets = []
    # p = Popen(["tshark", "-r", target, "-T", "fields", "-e", "frame.time_epoch", "-e", "_ws.col.Protocol", "-e", "ip.src", "-e", "tcp.srcport", "-e", "ip.dst", "-e", "tcp.dstport", "-e", "frame.len"], stdin=PIPE, stdout=PIPE, stderr=PIPE)
    p = Popen(["tshark", "-r", f"{target}.nictrace", "-T", "fields", "-e", "frame.time_epoch", "-e", "ip.src", "-e", "tcp.srcport", "-e", "ip.dst", "-e", "tcp.dstport", "-e", "frame.len"], stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = [msg.decode() for msg in p.communicate()]
    rc = p.returncode
    # print("STDOUT:\n", output)
    # print("STDERR:\n", err)
    for line in output.split("\n"):
        if len(line.strip().split()) != 6:
            continue
        timestamp, src, src_port, dst, dst_port, pkt_len = [item.strip() for item in line.split("\t")]
        src = src.split(",")[-1].strip()
        dst = dst.split(",")[-1].strip()
        packet = Packet(timestamp, src, src_port, dst, dst_port, pkt_len, "tcp")
        # if packet.timestamp < 0 or packet.timestamp > 400 + 7 * 60:
        if packet.timestamp < 0:
            continue
        packets.append(packet)


    p = Popen(["tshark", "-r", f"{target}.nictrace", "-T", "fields", "-e", "frame.time_epoch", "-e", "ip.src", "-e", "udp.srcport", "-e", "ip.dst", "-e", "udp.dstport", "-e", "frame.len"], stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = [msg.decode() for msg in p.communicate()]
    rc = p.returncode
    # print("STDOUT:\n", output)
    # print("STDERR:\n", err)
    for line in output.split("\n"):
        if len(line.strip().split()) != 6:
            continue
        timestamp, src, src_port, dst, dst_port, pkt_len = [item.strip() for item in line.split("\t")]
        src = src.split(",")[-1].strip()
        dst = dst.split(",")[-1].strip()
        packet = Packet(timestamp, src, src_port, dst, dst_port, pkt_len, "udp")
        if packet.timestamp < 0 or packet.timestamp > 400 + 7 * 60:
            continue
        packets.append(packet)

    for line in output.split("\n"):
        packet_content = line.strip().split()
        if len(packet_content) >= 4 or len(packet_content) < 2:
            continue
        timestamp, pkt_len = packet_content[0], packet_content[-1]
        packet = Packet(timestamp, "", "", "", "", pkt_len, "other")
        # if packet.timestamp < 0 or packet.timestamp > 400 + 7 * 60:
        if packet.timestamp < 0:
            continue
        packets.append(packet)
        # timestamp, src, src_port, dst, dst_port, pkt_len = [item.strip() for item in line.split("\t")]
        # packets.append(Packet(timestamp, src, src_port, dst, dst_port, pkt_len, "udp"))

    packets = sorted(packets, key=lambda x: x.timestamp)
    print(f"Packet Arr Len: {len(packets)}")

    # matplotlib init
    plt.rc('font', size=24)
    plt.rc('axes', titlesize=24)
    plt.rc('xtick', labelsize=24)
    plt.rc('ytick', labelsize=24)
    plt.rc('legend', fontsize=30)

    fig, axs = plt.subplots(total_figures, 1, figsize=(26, 5 * total_figures))
    axs_cmd = ",".join([f"ax{i}" for i in range(total_figures)]) + "=axs"
    exec(axs_cmd)

    bio_total_time = bios[-1].timestamp if len(bios) != 0 else 0 
    packet_total_time = packets[-1].timestamp if len(packets) != 0 else 0 
    total_time = max(bio_total_time, packet_total_time)
    total_bins = ceil(total_time / bin_size) + 1 

    # block IO processing
    rd = [bio for bio in bios if bio.op == "read"]
    wr = [bio for bio in bios if bio.op == "write"]
    rd_hit = [bio for bio in bios if bio.op == "read" and bio.hit]
    wr_hit = [bio for bio in bios if bio.op == "write" and bio.hit]
    rd_miss = [bio for bio in bios if bio.op == "read" and not bio.hit]
    wr_miss = [bio for bio in bios if bio.op == "write" and not bio.hit]
    print(f"BIO Read Arr Len: {len(rd)}")
    print(f"BIO Write Arr Len: {len(wr)}")
    print(f"BIO Read Hit Arr Len: {len(rd_hit)}")
    print(f"BIO Write Hit Arr Len: {len(wr_hit)}")
    print(f"BIO Read Miss Arr Len: {len(rd_miss)}")
    print(f"BIO Write Miss Arr Len: {len(wr_miss)}")

    colors_roller_6 = ["#57B4E9", "#019E73", "#E69F00", "#B21000", "#5B0680", "#0072B2"]

    ax = axs[0]
    ax.scatter([bio.timestamp for bio in rd], [bio.lpa for bio in rd], label="LPA Read", color=colors_roller_6[0])
    ax.scatter([bio.timestamp for bio in wr], [bio.lpa for bio in wr], label="LPA Write", color=colors_roller_6[1])

    ax = axs[1]
    ax.scatter([bio.timestamp for bio in rd_miss], [bio.lpa for bio in rd_miss], label="Read Miss", color=colors_roller_6[2])
    ax.scatter([bio.timestamp for bio in wr_miss], [bio.lpa for bio in wr_miss], label="Write Miss", color=colors_roller_6[3])
    ax.scatter([bio.timestamp for bio in rd_hit], [bio.lpa for bio in rd_hit], label="Read Hit", color=colors_roller_6[0])
    ax.scatter([bio.timestamp for bio in wr_hit], [bio.lpa for bio in wr_hit], label="Write Hit", color=colors_roller_6[1])
    print(f"BIO plot complete")

    # network packet processing
    sent = [packet for packet in packets if packet.src == host]
    recv = [packet for packet in packets if packet.dst == host]
    print(f"Packet Send Arr Len: {len(sent)}")
    print(f"Packet Receive Arr Len: {len(recv)}")

    malicious_sent = []
    malicious_recv = []
    for packet in packets:
        for malicious_ip in malicious_ips:
            if packet.dst.startswith(malicious_ip):
                malicious_sent.append(packet)
                break
            if packet.src.startswith(malicious_ip):
                malicious_recv.append(packet)
                break
    print(f"Malicious packet Send Arr Len: {len(malicious_sent)}")
    print(f"Malicious packet Receive Arr Len: {len(malicious_recv)}")

    sent_size = [0 for _ in range(total_bins)]
    recv_size = [0 for _ in range(total_bins)]
    sent_cnt = [0 for _ in range(total_bins)]
    recv_cnt = [0 for _ in range(total_bins)]
    for sent_pkt in sent:
        sent_size[floor(sent_pkt.timestamp / bin_size)] += sent_pkt.pkt_len
        sent_cnt[floor(sent_pkt.timestamp / bin_size)] += 1
    for recv_pkt in recv:
        recv_size[floor(recv_pkt.timestamp / bin_size)] += recv_pkt.pkt_len
        recv_cnt[floor(recv_pkt.timestamp / bin_size)] += 1
    sent_size = [size / bin_size * 8 / 1024 ** 2 for size in sent_size]
    recv_size = [size / bin_size * 8 / 1024 ** 2 for size in recv_size]
    total_size = [sent + recv for sent, recv in zip(sent_size, recv_size)]
    total_cnt = [sent + recv for sent, recv in zip(sent_cnt, recv_cnt)]

    malicious_sent_size = [0 for _ in range(total_bins)]
    malicious_recv_size = [0 for _ in range(total_bins)]
    malicious_sent_cnt = [0 for _ in range(total_bins)]
    malicious_recv_cnt = [0 for _ in range(total_bins)]
    for sent_pkt in malicious_sent:
        malicious_sent_size[floor(sent_pkt.timestamp / bin_size)] += sent_pkt.pkt_len
        malicious_sent_cnt[floor(sent_pkt.timestamp / bin_size)] += 1
    for recv_pkt in malicious_recv:
        malicious_recv_size[floor(recv_pkt.timestamp / bin_size)] += recv_pkt.pkt_len
        malicious_recv_cnt[floor(recv_pkt.timestamp / bin_size)] += 1
    malicious_sent_size = [size / bin_size * 8 / 1024 ** 2 for size in malicious_sent_size]
    malicious_recv_size = [size / bin_size * 8 / 1024 ** 2 for size in malicious_recv_size]
    malicious_total_size = [sent + recv for sent, recv in zip(malicious_sent_size, malicious_recv_size)]
    malicious_total_cnt = [sent + recv for sent, recv in zip(malicious_sent_cnt, malicious_recv_cnt)]

    ax = axs[network_figure_start]
    ax.scatter([packet.timestamp for packet in sent], [packet.pkt_len for packet in sent],label="Sent")
    ax.scatter([packet.timestamp for packet in recv], [packet.pkt_len for packet in recv],label="Recv")
    if malicious_ips != ["x"]:
        ax.scatter([packet.timestamp for packet in malicious_sent], [packet.pkt_len for packet in malicious_sent],label="Malicious Sent")
        ax.scatter([packet.timestamp for packet in malicious_recv], [packet.pkt_len for packet in malicious_recv],label="Malicious Recv")

    ax = axs[network_figure_start + 1]
    ax.plot(np.arange(total_bins) * bin_size, sent_size, label="Sent Size", linewidth=3, linestyle="-")
    ax.plot(np.arange(total_bins) * bin_size, recv_size, label="Recv Size", linewidth=3, linestyle="-")
    # ax.plot(np.arange(total_bins) * bin_size, total_size, label="Total Size", linewidth=3, linestyle="-")

    ax = axs[network_figure_start + 2]
    ax.plot(np.arange(total_bins) * bin_size, sent_cnt, label="Sent Count", linewidth=3, linestyle="-")
    ax.plot(np.arange(total_bins) * bin_size, recv_cnt, label="Recv Count", linewidth=3, linestyle="-")
    # ax.plot(np.arange(total_bins) * bin_size, total_cnt, label="Total Count", linewidth=3, linestyle="-")

    # if malicious_ips != ["x"]:
    #     ax = axs[network_figure_start + 3]
    #     ax.scatter([packet.timestamp for packet in malicious_sent], [packet.pkt_len for packet in malicious_sent],label="Malicious Sent")
    #     ax.scatter([packet.timestamp for packet in malicious_recv], [packet.pkt_len for packet in malicious_recv],label="Malicious Recv")

    #     ax = axs[network_figure_start + 4]
    #     ax.plot(np.arange(total_bins) * bin_size, malicious_sent_size, label="Malicious Sent Size", linewidth=3, linestyle="-")
    #     ax.plot(np.arange(total_bins) * bin_size, malicious_recv_size, label="Malicious Recv Size", linewidth=3, linestyle="-")
    #     # axs[network_figure_start + 1].plot(np.arange(total_bins) * bin_size, total_size, label="Total Size", linewidth=3, linestyle="-")

    #     ax = axs[network_figure_start + 5]
    #     ax.plot(np.arange(total_bins) * bin_size, malicious_sent_cnt, label="Malicious Sent Count", linewidth=3, linestyle="-")
    #     ax.plot(np.arange(total_bins) * bin_size, malicious_recv_cnt, label="Malicious Recv Count", linewidth=3, linestyle="-")
    #     # ax.plot(np.arange(total_bins) * bin_size, total_cnt, label="Total Count", linewidth=3, linestyle="-")
    print(f"Packet plot complete")

    for ax in axs:
        ax.legend(loc="upper center", bbox_to_anchor=(0.5, 1.45), ncol=5)
        ax.grid(linestyle='-', linewidth=1.5)
        ax.set_ylim([0, ax.get_ylim()[1]])
        xlim = [0, total_time]
        if total_time_override_start != None:
            xlim[0] = total_time_override_start
        if total_time_override_end != None:
            xlim[1] = total_time_override_end
        ax.set_xlim(xlim)
        if start_exe_time != None:
            ymin, ymax = ax.get_ylim()
            ax.axvline(x=start_exe_time-bio_start_time, color="black", linestyle="--")
        if end_time != None:
            ymin, ymax = ax.get_ylim()
            ax.axvline(x=end_time-bio_start_time, color="black", linestyle="--")

    ax = axs[0]
    ax.set_ylabel("Logical Address")
    ax.set_xlabel("Time (sec)")
    ax.set_ylim([0, 2e10])

    ax = axs[1]
    ax.set_ylabel("Logical Address")
    ax.set_xlabel("Time (sec)")
    ax.set_ylim([0, 2e10])

    ax = axs[network_figure_start]
    ax.set_ylabel("Packet Size (byte)")
    ax.set_xlabel("Time (sec)")
    # ax.set_ylim([0, 1500])

    ax = axs[network_figure_start + 1]
    ax.set_ylabel("Traffic (Mbps)")
    ax.set_xlabel("Time (sec)")
    xlim = ax.get_xlim()
    ylim = ax.get_ylim()
    ax.set_ylim([ylim[0], max(total_size[floor(xlim[0] / bin_size):ceil(xlim[1] / bin_size)]) * 1.2])

    ax = axs[network_figure_start + 2]
    ax.set_ylabel("Packet Count")
    ax.set_xlabel("Time (sec)")
    xlim = ax.get_xlim()
    ax.set_ylim([ylim[0], max(total_cnt[floor(xlim[0] / bin_size):ceil(xlim[1] / bin_size)]) * 1.2])


    # ax = axs[network_figure_start + 3]
    # ax.set_ylabel("Packet Size (byte)")
    # ax.set_xlabel("Time (sec)")

    # ax = axs[network_figure_start + 4]
    # ax.set_ylabel("Traffic (Mbps)")
    # ax.set_xlabel("Time (sec)")
    # xlim = ax.get_xlim()
    # ylim = ax.get_ylim()
    # ax.set_ylim([ylim[0], max(malicious_total_size[floor(xlim[0] / bin_size):ceil(xlim[1] / bin_size)]) * 1.2])

    # ax = axs[network_figure_start + 5]
    # ax.set_ylabel("Packet Count")
    # ax.set_xlabel("Time (sec)")
    # ax.set_ylim([ylim[0], max(malicious_total_cnt[floor(xlim[0] / bin_size):ceil(xlim[1] / bin_size)]) * 1.2])

    fig.subplots_adjust(hspace=0.8)
    # plt.show()

    p = Popen(["mkdir", "-p", dest_parent])
    p.communicate()

    with open(f"{target}.info", "r") as f:
        content = f.read()
        content_split = content.split("\n")
        content_split_new = []
        for content_line in content_split:
            skip = False
            for metric in metrics.values():
                if metric in content_line:
                    skip = True
                    break
            if not skip:
                content_split_new.append(content_line)
    end_idx = len(content_split_new)
    while end_idx > 0 and len(content_split_new[end_idx-1].strip()) == 0:
        end_idx -= 1
    with open(f"{trace_dest}.info", "w") as f:
        for line in content_split_new[:end_idx]:
            f.write(f"{line}\n")
        f.write(f"""
Trace Information:
  Start Execution Time: {(start_exe_time - bio_start_time):.2f} sec
  End Execution Time: {(end_time - bio_start_time):.2f} sec
""")

    extent = fig.get_window_extent().transformed(fig.dpi_scale_trans.inverted()).expanded(0.9, 0.9)
    # fig.savefig(f"{target}.pdf", bbox_inches=extent)
    # fig.savefig(f"{target}.png", bbox_inches=extent, facecolor="white")
    # fig.savefig(f"{trace_dest}.pdf", bbox_inches=extent)
    fig.savefig(f"{trace_dest}.png", bbox_inches=extent, facecolor="white")

    # dump trace
    trace_format = ["Timestamp", "LPA", "PPA", "Operation", "CacheHit"]
    with open(f"{trace_dest}.ssdtrace.csv", "w") as f:
        f.write(",".join(trace_format) + "\n")
        for bio in bios:
            f.write(f"{int(bio.timestamp * 1e6)}, {bio.lpa}, {bio.ppa}, {bio.op}, {bio.hit}\n")

    trace_format = ["Timestamp", "SourceIP", "SourcePort", "DestinationIP", "DestinationPort", "PacketLength", "Protocol"]
    with open(f"{trace_dest}.nictrace.csv", "w") as f:
        f.write(",".join(trace_format) + "\n")
        for packet in packets:
            f.write(f"{int(packet.timestamp * 1e6)}, {packet.src}, {packet.src_port}, {packet.dst}, {packet.dst_port}, {packet.pkt_len}, {packet.protocol}\n")
            
