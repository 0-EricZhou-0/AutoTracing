import sys, json, os

assert len(sys.argv) == 2
file_name = sys.argv[1]

json_name = os.path.basename(file_name)
sample_name = json_name.split(".")[0]
with open(f"{file_name}", "r") as f:
  info_json = json.load(f)

output_file = f"{file_name}.info"

info_json = info_json[0]
if "trid" in info_json:
  trid_info = info_json["trid"]
  trid_str = ""
  for trid_item in trid_info:
    file_type = trid_item["file_type"]
    file_probability = trid_item["probability"]
    trid_item_str = f"{file_probability}%: {file_type}"
    trid_str += f"{trid_item_str}\n          "
else:
  trid_str = "N/A"

virus_total_info = f"""VirusTotal Link: https://www.virustotal.com/gui/file/{sample_name}/"""

threat_label = f"""Threat Label: {info_json["popular_threat_classification"]["suggested_threat_label"]}"""

threat_category = []
all_categories = info_json["popular_threat_classification"]["popular_threat_category"]
for category_type_info in all_categories:
  threat_category.append(category_type_info["value"])
threat_category = f"""Threat Category: {", ".join(threat_category)}"""

hash_list = f"""Hashes:
  MD5       {info_json["md5"]      if "md5"      in info_json else "N/A"}
  SHA-1     {info_json["sha1"]     if "sha1"     in info_json else "N/A"}
  SHA-256   {info_json["sha256"]   if "sha256"   in info_json else "N/A"}
  Vhash     {info_json["vhash"]    if "vhash"    in info_json else "N/A"}
  SSDEEP    {info_json["ssdeep"]   if "ssdeep"   in info_json else "N/A"}
  TLSH      {info_json["tlsh"]     if "tlsh"     in info_json else "N/A"}
  Telfhash  {info_json["telfhash"] if "telfhash" in info_json else "N/A"}"""

type_info = f"""File Information:
  Type:   {" ".join(info_json["type_tags"])}  Magic:  {info_json["magic"]}
  TrID:   {trid_str}"""

print(f"""{virus_total_info}

{threat_label}

{threat_category}

{hash_list}

{type_info}
""")
