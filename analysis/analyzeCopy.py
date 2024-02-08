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

    packet_start_time = 0
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
    with open(f"{target}.ssdtrace.csv") as f:
        for line in f:
            timestamp, lpa, ppa, op, hit = [s.strip() for s in line.split(",")]
            bios.append(BlockIO(timestamp, lpa, ppa, op, hit))

    bios = sorted(bios, key=lambda x: x.timestamp)
    print(f"Block IO Arr Len: {len(bios)}")

    packets = []
    with open(f"{target}.ssdtrace.csv") as f:
        for line in f:
            timestamp, src, src_port, dst, dst_port, pkt_len = [s.strip() for s in line.split(",")]
            packets.append(packet)

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

    extent = fig.get_window_extent().transformed(fig.dpi_scale_trans.inverted()).expanded(0.9, 0.9)
    # fig.savefig(f"{target}.pdf", bbox_inches=extent)
    # fig.savefig(f"{target}.png", bbox_inches=extent, facecolor="white")
    # fig.savefig(f"{trace_dest}.pdf", bbox_inches=extent)
    fig.savefig(f"{trace_dest}.png", bbox_inches=extent, facecolor="white")
