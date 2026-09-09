#!/bin/bash

###############################################################################
# NextDNS Free Fire Vietnam Blocker - Setup Script
# Script tự động cài đặt và cấu hình NextDNS để chặn Free Fire
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
    print_success "Running as root"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        DISTRO=$(lsb_release -si 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macOS"
    else
        OS="unknown"
    fi
    print_info "Detected OS: $DISTRO"
}

# Install NextDNS CLI
install_nextdns_cli() {
    print_header "Installing NextDNS CLI"
    
    if command -v nextdns &> /dev/null; then
        print_warning "NextDNS CLI already installed"
        return
    fi
    
    if [[ "$OS" == "linux" ]]; then
        print_info "Installing for Linux..."
        sh -c 'sh -c "$(curl -sL https://nextdns.io/install)"'
    elif [[ "$OS" == "macos" ]]; then
        print_info "Installing for macOS..."
        brew install nextdns || sh -c 'sh -c "$(curl -sL https://nextdns.io/install)"'
    fi
    
    if command -v nextdns &> /dev/null; then
        print_success "NextDNS CLI installed successfully"
    else
        print_error "Failed to install NextDNS CLI"
        exit 1
    fi
}

# Configure NextDNS with Free Fire blocklist
configure_nextdns() {
    print_header "Configuring NextDNS"
    
    print_info "Please enter your NextDNS Profile ID (found at https://my.nextdns.io/)"
    read -p "Profile ID: " PROFILE_ID
    
    if [ -z "$PROFILE_ID" ]; then
        print_error "Profile ID cannot be empty"
        exit 1
    fi
    
    print_info "Configuring NextDNS with Profile ID: $PROFILE_ID"
    
    # Apply configuration
    if nextdns config -profile "$PROFILE_ID" 2>/dev/null; then
        print_success "NextDNS configured successfully"
    else
        print_error "Failed to configure NextDNS"
        print_info "Please configure manually at: https://my.nextdns.io/profiles/$PROFILE_ID"
        return 1
    fi
}

# Add blocklist entries
add_blocklist_entries() {
    print_header "Adding Blocklist Entries"
    
    print_info "Reading blocked domains from blocked-domains.txt..."
    
    if [ ! -f "blocked-domains.txt" ]; then
        print_error "blocked-domains.txt not found"
        print_info "Please make sure you're in the repository directory"
        exit 1
    fi
    
    print_warning "Note: Automatic blocklist upload requires NextDNS API key"
    print_info "For manual setup, please visit: https://my.nextdns.io/"
    print_info "1. Go to your Profile"
    print_info "2. Navigate to Denylist → Custom Rules"
    print_info "3. Add domains from blocked-domains.txt"
    
    # Count entries
    DOMAIN_COUNT=$(grep -v "^#" blocked-domains.txt | grep -v "^$" | wc -l)
    IP_COUNT=$(grep -v "^#" blocked-ips.txt 2>/dev/null | grep -v "^$" | wc -l)
    
    print_success "Found $DOMAIN_COUNT domains and $IP_COUNT IP ranges to block"
}

# Test DNS blocking
test_dns_blocking() {
    print_header "Testing DNS Blocking"
    
    print_info "Testing if Free Fire domains are blocked..."
    
    TEST_DOMAINS=("freefiremobile.com" "ff.garena.com" "freefireind.in")
    
    for domain in "${TEST_DOMAINS[@]}"; do
        print_info "Testing: $domain"
        
        if nslookup "$domain" 127.0.0.1 &>/dev/null; then
            print_warning "Domain still resolves: $domain (blocking may not be active yet)"
        else
            print_success "Domain blocked: $domain"
        fi
    done
}

# Display summary
display_summary() {
    print_header "Setup Complete!"
    
    echo ""
    echo -e "${GREEN}Summary:${NC}"
    echo "  • NextDNS CLI installed: $(command -v nextdns &>/dev/null && echo 'Yes' || echo 'No')"
    echo "  • NextDNS configured: Yes"
    echo "  • Domains to block: $DOMAIN_COUNT"
    echo "  • IP ranges to block: $IP_COUNT"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Visit https://my.nextdns.io/"
    echo "  2. Add domains from blocked-domains.txt to your Denylist"
    echo "  3. Add IP ranges from blocked-ips.txt to your IP blocklist"
    echo "  4. Run: nextdns start"
    echo "  5. Test with: nslookup freefiremobile.com"
    echo ""
    echo -e "${BLUE}Documentation:${NC}"
    echo "  • NextDNS Docs: https://nextdns.io/docs"
    echo "  • Repository: https://github.com/huyquoc29098-cyber/nextdns-ff-blocker"
    echo ""
}

# Main execution
main() {
    clear
    print_header "NextDNS Free Fire Vietnam Blocker Setup"
    
    print_info "This script will help you block Free Fire Vietnam servers using NextDNS"
    echo ""
    
    # Check prerequisites
    detect_os
    
    # Ask for confirmation
    read -p "Do you want to continue? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "y" ]]; then
        print_info "Setup cancelled"
        exit 0
    fi
    
    # Run installation steps
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "macos" ]]; then
        check_root
        install_nextdns_cli
        configure_nextdns
        add_blocklist_entries
        # Uncomment below to test
        # test_dns_blocking
        display_summary
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Run main function
main "$@"
