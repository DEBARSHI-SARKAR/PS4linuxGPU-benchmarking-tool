#!/bin/bash

LOGFILE="gpu_advanced_test_ps4_$(date +%Y%m%d_%H%M%S).log"

echo "===== PS4 GPU ADVANCED TEST =====" | tee -a "$LOGFILE"
echo "Log file: $LOGFILE" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

# Function to check and install packages
install_if_missing() {
    if ! command -v $1 &>/dev/null; then
        echo "Installing $1..." | tee -a "$LOGFILE"
        sudo apt update
        sudo apt install -y $2 | tee -a "$LOGFILE"
    fi
}

# Install required tools
install_if_missing glmark2 glmark2
install_if_missing vulkaninfo vulkan-tools
install_if_missing vkmark vkmark
install_if_missing stress-ng stress-ng
install_if_missing sensors lm-sensors

# Hardware detection
echo "=== Detecting PS4 GPU ===" | tee -a "$LOGFILE"
lspci -k | grep -iE "vga|amd|radeon|amdgpu" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

# Temperature monitoring function
monitor_temp() {
    echo "=== LIVE TEMPERATURE MONITORING ===" | tee -a "$LOGFILE"
    echo "Press CTRL+C to stop." | tee -a "$LOGFILE"
    echo "" | tee -a "$LOGFILE"

    while true; do
        sensors | tee -a "$LOGFILE"
        sleep 2
        echo "--------------------------" | tee -a "$LOGFILE"
    done
}

# Stress test function
run_stress_test() {
    echo "=== GPU/CPU STRESS TEST (5 minutes) ===" | tee -a "$LOGFILE"
    echo "Running stress-ng on GPU-related operations..." | tee -a "$LOGFILE"

    stress-ng --cpu 8 --matrix 4 --timeout 5m --metrics-brief | tee -a "$LOGFILE"
}

# Benchmarks
run_glmark() {
    echo "=== OpenGL Benchmark (glmark2) ===" | tee -a "$LOGFILE"
    glmark2 | tee -a "$LOGFILE"
}

run_vkmark() {
    echo "=== Vulkan Benchmark (vkmark) ===" | tee -a "$LOGFILE"
    vkmark | tee -a "$LOGFILE"
}

run_vulkaninfo() {
    echo "=== Vulkan Info ===" | tee -a "$LOGFILE"
    vulkaninfo | tee -a "$LOGFILE"
}

# Main menu
while true; do
    echo ""
    echo "========== PS4 ADVANCED GPU TEST MENU =========="
    echo "1) Run OpenGL Test"
    echo "2) Run Vulkan Test"
    echo "3) Show Vulkan Information"
    echo "4) Stress Test GPU/CPU (5 minutes)"
    echo "5) Temperature Monitoring"
    echo "6) Run ALL Tests"
    echo "7) Exit"
    echo "================================================"
    read -p "Choose an option: " CHOICE

    case $CHOICE in
        1) run_glmark ;;
        2) run_vkmark ;;
        3) run_vulkaninfo ;;
        4) run_stress_test ;;
        5) monitor_temp ;;
        6)
            run_glmark
            run_vkmark
            run_vulkaninfo
            run_stress_test
            ;;
        7)
            echo "Done. Results saved to: $LOGFILE"
            exit 0
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
done
