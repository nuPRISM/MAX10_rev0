#! /tools/cfr/bin/python

################################################################
##
## Used for add module prefix in netlist
## written by donghua.gu@lsi.com
## Thu Dec 22 22:58:45 CST 2011
##
################################################################

import re
import os
import sys
import gzip
import copy
from optparse import OptionParser


def get_all_module_names(lines):
  patt = """^\s*module\s+([^\( ]*)"""
  module_names = []
  for line in lines:
    if not line: continue
    module_name = re.findall(patt, line)
    if module_name:
      module_name = "".join(module_name)
      module_names.append(module_name)
  return module_names

def get_top_modue_name(module_names, lines):
  module_name_all = set(module_names)
  module_name_used = set()
  patt_instance = """^([A-Za-z0-9_]+)\s+([A-Za-z0-9_]+)\s*\("""
  for line in lines:
    line = line.strip()
    if not line: continue
    module_instance_pairs = re.findall(patt_instance, line)
    if not module_instance_pairs:
      continue
    else:
      module = module_instance_pairs[0][0]
      module_name_used.add(module)

  not_used = module_name_all.difference(module_name_used)
  return not_used


def prefix_module_names(lines, module_names, prefix, fixed_module_names,original_lines):
  new_lines = []
  module_name_set = set(module_names)
  #patt_instance = """^([A-Za-z0-9_]+)\s+([A-Za-z0-9_]+)\s+\("""
  patt_instance = """^([A-Za-z0-9_]+)\s+([A-Za-z0-9_\#]+)\s*\("""
  patt_module = """^module\s([^\s]*)\s*[\(\n]"""
  line_counter = 0;
  for line in lines:
    original_line = original_lines[line_counter]
    line_counter=line_counter+1
    line_has_changed = False
    if not line.strip():
      new_lines.append(line + "\n")
      continue
    line = line.strip() + "\n"
    new_line = line
    module_instance_pairs = re.findall(patt_instance, line)
    if module_instance_pairs:
      module_name = module_instance_pairs[0][0]
      if module_name in fixed_module_names:
        pass
      elif module_name in module_name_set:
        #print line
        line_has_changed = True
        new_line = prefix + line.strip() + "\n";

    module_name = re.findall(patt_module, line)
    if module_name:
      module_name = "".join(module_name)
      if module_name in fixed_module_names:
        pass
      else:
        line_has_changed = True
        new_line = "module " + prefix + line[len("module "):].strip() + "\n";
		
    if line_has_changed:
      new_lines.append(new_line)
    else: 
      new_lines.append(original_line)
  return new_lines

if __name__=="__main__":

  usage = "usage: %prog [options] netlist ...\n"
  usage +="\nSave prefixed netlist to file netlist[p]"
  parser = OptionParser(usage=usage)
  #parser.add_option("-o", dest="output_file",
  #                  help="file name for modified verilog netlist", metavar="OUTPUT")
  parser.add_option("-p", "--prefix", dest="prefix",
                    help="prefix for module names, default pre", metavar="PREFIX", default="pre")
  parser.add_option("-f", "--fixed", dest="fixed",
                    help="fixed module names", metavar="FIXED", default="")
  (options, args) = parser.parse_args()
  verilog_files = args
  prefix  = options.prefix
  fixed   = options.fixed.split()
  #out_file   = options.out_file

  if len(verilog_files) > 1:
    prefixs = [prefix+"_"+str(i) for i in range(len(verilog_files))]
  else:
    prefixs = [ prefix ]
  for i in range(len(verilog_files)):
    v_file = verilog_files[i]
    print("Proecess ",v_file)
    if v_file.endswith(".gz"):
      gf    = gzip.open(v_file, 'rb')
      lines = gf.readlines()
      gf.close()
      new_name = v_file[:-3] + "p"
    else:
      lines = open(v_file, 'r').readlines()
      new_name = v_file + "p"
    original_lines = lines; 
    lines = [line.strip() for line in lines]

    module_names = get_all_module_names(lines)
    module_not_used = get_top_modue_name(module_names, lines)
    #for m in module_not_used:
    #  fixed.append(m)
    #
    #if (not prefix) or (prefix=="pre"):
    #  mprefix = "".join(module_not_used) + "_"
    #else:
    #  mprefix = prefixs[i] + "_"
    mprefix = prefixs[i] + "_"

    print("  prefix: ",mprefix)
    print("   fixed:  ",fixed)
    print(" modules:  ",module_names)
    new_lines = prefix_module_names(lines, module_names, mprefix, fixed,original_lines)
    v_new = "".join(new_lines)

    if os.path.exists(new_name):
      cmd = "mv %s %s" % (new_name, new_name + ".bk") 
      os.system(cmd)
    open(new_name, 'w').write(v_new)
    print("    Save ",new_name)
    #break
