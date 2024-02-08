# %%
import numpy as np
import os
import math
import re
import matplotlib.pyplot as plt

# pattern = re.compile(r'')
filename = ["./new-log.txt"]


SEC = 1000000000
MILI = 1000000
# windows should be the second
window = 10*SEC

TIME = 0
LPA = 1
PPA = 2
TYPE = 3
HIT = 4

READ = 0
WRITE = 3

print("window:",window)

test = "208 TIME:2010131333120 ADDR:1074289378 TYPE:2 HIT:01"
pattern = r'\d+ TIME:(\d+) ADDR:(\d+) phy:(\d+) TYPE:(\d+) HIT:(\d+)'

p = re.compile(pattern)
# result = re.match(pattern,test)
# print(result.group())

lines = []
for f in filename:
    with open(f) as fp:
        for i, raw in enumerate(fp):
            # parse trace
            result = re.match(pattern,raw)
            if result == None:
                continue
            if (int(result.group(LPA + 1)) > 1e7):
                continue
            if (int(result.group(PPA + 1)) > 1e7):
                continue
            if (int(result.group(TIME + 1)) == 0):
                continue
            lines.append([int(result.group(j)) for j in range(1, 6)])
start_time = lines[0][0]
end_time = lines[len(lines) - 1][0]
print(f"Run from {start_time} ms to {end_time} ms")
print(f"total {end_time - start_time} ms or {(end_time - start_time) / 10e9} s")
data = np.zeros((len(lines), len(lines[0])), dtype=float)
for i in range(len(lines)):
    data[i, :] = lines[i]

# normalize and convert to second
data[:, TIME] = (data[:, TIME] - start_time) / 10e9

data[: TIME]

time_interval = [40, 60]

read_idxs = data[:, TYPE] == READ
write_idxs = data[:, TYPE] == WRITE

plt.rc('font', size=24)
plt.rc('axes', titlesize=24)
plt.rc('xtick', labelsize=28)
plt.rc('ytick', labelsize=24)
plt.rc('legend', fontsize=35)

target = LPA
fig, ax = plt.subplots(1, 1, figsize=(26, 10))
ax.scatter(data[:, TIME][read_idxs], data[:, target][read_idxs],label="Read")
ax.scatter(data[:, TIME][write_idxs], data[:, target][write_idxs],label="Write")



# plt.legend()
# plt.ylim([1.53e5, 1.57e5])
# plt.ylim([1.4e5, 1.8e5])
ax.set_xlabel("Time (s)", fontsize=36)
if target == LPA:
    ax.set_ylabel("Logical Page Address", fontsize=36)
    # ax.set_xlim([5.8, 16])
    # ax.set_ylim([0, 9e5])
    # ax.set_ylim([1.53e5, 1.57e5])
    ax.set_ylim([1.4e5, 1.8e5])
else:
    ax.set_ylabel("Physical Page Address", fontsize=36)
    # ax.set_xlim([5.8, 16])
    # ax.set_ylim([0, 1.7e6])
ax.legend(loc="upper center", bbox_to_anchor=(0.5, 1.1), ncol=2)
ax.grid()

extent = fig.get_window_extent().transformed(fig.dpi_scale_trans.inverted()).expanded(0.9, 0.9)
fig.savefig("output.pdf", bbox_inches=extent)
fig.savefig("output.png", bbox_inches=extent)
