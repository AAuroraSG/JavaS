#!/usr/bin/python
# encoding=utf-8

import sys
import os
import subprocess
import re
import configparser
from argparse import ArgumentError

h = \
"""JavaS Version: 0.0.4
JavaS <-h | --help>
	-h | --help : Show help
	When the help parameter is in any position,
	it will be treated as the command "JavaS -h"
	But if you want to run "JavaS -v* java -h",
	you can use the command "JavaS -v* java"
JavaS <-v | --version>[java version] <command> [args]
	-v | --version : java version
	<command> [args]: java command
"""

cfg = \
r"""[JavaPath]
# java17 = C:\Program Files\java\java-17
java8  =
java11 =
java17 =
java21 =
java25 =
java26 =
"""

cfg_p = os.path.abspath("JavaS.cfg")

# noinspection pep8-naming
def JavaS(*args: str):
	if len(args) >= 1:
		args = ' '.join(str(temp) for temp in args)
		args = args.split(" ")
		args1 = []
		for temp in args:
			if temp: args1.append(temp)
		args = args1

	else:
		print("Java [Error]: Argument Is Empty")
		raise ArgumentError

	if '-h' in args or '--h' in args or '-help' in args or '--help' in args: print(h);return

	arg1 = args[0]

	args = ' '.join(temp for temp in args[1:])

	if len(args) <= 0:
		raise Exception("Java [Error]: The java command is none")

	rv = re.findall(r"^(-v|--v|-version|--version)(\d*)$", arg1)
	jv = rv[0][1]

	if jv:
		if os.path.exists(cfg_p):
			config = configparser.ConfigParser()
			config.read(cfg_p, encoding='utf-8')

			jp = config["JavaPath"][f"java{jv}"]
			if not jp:
				raise configparser.NoOptionError
			if not os.path.exists(jp): print(f"JavaS [Error]: Path does not exist - {jp}")

		else:
			with open(cfg_p, 'a', encoding="utf-8") as f: f.write(cfg)
			print("JavaS [Error]: File isn't found and auto create")
			raise FileNotFoundError("JavaS [Error]: FileNotFound, NoOptionError")

	else:
		a = subprocess.run("cmd /c \"echo %JAVA_HOME%\"", shell=True, capture_output=True, text=True)
		if a.returncode != 0 or not a.stdout:
			raise Exception("JavaS [Error]: JAVA_HOME does not exist")
		jp = a.stdout[:-1]
		print(f"JavaS [Info]: default {jp}")

	r = subprocess.run(rf'{args}', shell=True, capture_output=True, text=True, env={"JAVA_HOME": f"{jp}", "Path": rf"{jp}" + r"\bin"})
	if r.returncode == 0:print(r.stdout)
	elif r.returncode !=0:print(r.stderr)

if __name__=="__main__":
	"""
	JavaS(*sys.argv[1:])
	model: Not recommended
	JavaS("-v21 java --version")
	shell:
	python.exe JavaS.py "-v21 javac --version"
	"""
	JavaS(*sys.argv[1:])
	...