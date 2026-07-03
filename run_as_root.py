import pty
import os
import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: run_as_root.py <command> [args...]")
        sys.exit(1)
        
    cmd = sys.argv[1:]
    doas_cmd = ["doas"] + cmd
    
    pid, fd = pty.fork()
    if pid == 0:
        os.execvp("doas", doas_cmd)
    else:
        output = b""
        try:
            while b"password" not in output.lower():
                chunk = os.read(fd, 1)
                if not chunk:
                    break
                output += chunk
                if chunk == b'\n':
                    sys.stdout.buffer.write(output)
                    sys.stdout.flush()
                    output = b""
            
            if b"password" in output.lower():
                os.write(fd, b"yuk11nn4\n")
            else:
                sys.stdout.buffer.write(output)
                sys.stdout.flush()
                
            while True:
                chunk = os.read(fd, 1024)
                if not chunk:
                    break
                sys.stdout.buffer.write(chunk)
                sys.stdout.flush()
        except OSError:
            pass

if __name__ == "__main__":
    main()
