import os
import sys
import subprocess
import argparse
import time
from typing import List

class LocalCI:
    def __init__(self) -> None:
        self.start_time = time.time()
        self.steps_passed = 0
        self.steps_failed = 0

    def run_command(self, name: str, command: List[str]) -> bool:
        print(f"\n[{name}] Starting...")
        try:
            is_windows = sys.platform.startswith('win')
            run_cmd = " ".join(command) if is_windows else command
            
            result = subprocess.run(
                run_cmd,
                stdout=sys.stdout,
                stderr=sys.stderr,
                text=True,
                check=False,
                shell=is_windows
            )
            if result.returncode == 0:
                print(f"[{name}] SUCCESS")
                self.steps_passed += 1
                return True
            print(f"[{name}] FAILED (Exit Code: {result.returncode})")
            self.steps_failed += 1
            return False
        except Exception as e:
            print(f"[{name}] ERROR: {str(e)}")
            self.steps_failed += 1
            return False

    def ensure_dummy_env(self) -> None:
        if not os.path.exists(".env"):
            with open(".env", "w", encoding="utf-8") as f:
                f.write("")

    def print_summary(self) -> None:
        duration = time.time() - self.start_time
        print("\n" + "="*40)
        print("LOCAL CI SUMMARY")
        print("="*40)
        print(f"Time Taken   : {duration:.2f} seconds")
        print(f"Steps Passed : {self.steps_passed}")
        print(f"Steps Failed : {self.steps_failed}")
        if self.steps_failed > 0:
            print("STATUS       : FAILED")
            sys.exit(1)
        print("STATUS       : SUCCESS")
        print("="*40)

def main() -> None:
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(project_root)

    parser = argparse.ArgumentParser(description="Local CI Pipeline")
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--skip-tests", action="store_true")
    args = parser.parse_args()

    if not os.path.exists("pubspec.yaml"):
        print(f"Error: pubspec.yaml not found in {project_root}")
        sys.exit(1)

    ci = LocalCI()
    ci.ensure_dummy_env()
    
    if not ci.run_command("Pub Get", ["flutter", "pub", "get"]):
        ci.print_summary()

    if not ci.run_command("Format", ["dart", "format", "lib/", "test/"]):
        ci.print_summary()

    if not ci.run_command("Analyze", ["flutter", "analyze", "--no-fatal-infos"]):
        ci.print_summary()

    if not args.skip_tests:
        if not ci.run_command("Test", ["flutter", "test"]):
            ci.print_summary()

    if not args.skip_build:
        build_cmd = [
            "flutter", "build", "apk", "--release",
            "--split-per-abi", "--obfuscate",
            "--split-debug-info=build/debug-info/"
        ]
        if not ci.run_command("Build APK", build_cmd):
            ci.print_summary()

    ci.print_summary()

if __name__ == "__main__":
    main()
