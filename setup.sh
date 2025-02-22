#!/bin/bash

# Print status function
print_status() {
    echo "→ $1"
}

# Check for system requirements
print_status "Checking system requirements..."

# Check for Homebrew and install if needed
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure correct Node.js version (as specified in package.json engines)
print_status "Checking Node.js version..."
if ! command -v node &> /dev/null || [ $(node -v | cut -d. -f1 | tr -d 'v') -lt 18 ]; then
    print_status "Installing Node.js 18..."
    brew install node@18
    echo 'export PATH="/usr/local/opt/node@18/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
fi

# Install Yarn if not present
if ! command -v yarn &> /dev/null; then
    print_status "Installing Yarn..."
    brew install yarn
fi

# For M1/M2 Macs, install Rosetta if needed
if [[ $(uname -m) == 'arm64' ]]; then
    print_status "Installing Rosetta for Apple Silicon..."
    softwareupdate --install-rosetta --agree-to-license
fi

# Install project dependencies
print_status "Installing project dependencies..."
yarn install

# Install peer dependencies explicitly
print_status "Installing peer dependencies..."
yarn add @shopify/flash-list@'^1.7.3' \
        react-native-keyboard-controller@'^1.16.3' \
        react-native-reanimated@'^3.16.7'

# Setup development environment
print_status "Setting up development environment..."
cat > .env << EOL
REACT_APP_PARENT_PASSWORD=default_password_change_me
REACT_APP_DEFAULT_MODEL=gpt-3.5-turbo
REACT_APP_MAX_MESSAGES_DEFAULT=50
EOL

# Add additional dependencies for parent-child feature
print_status "Adding parent-child feature dependencies..."
yarn add @radix-ui/react-alert-dialog \
        @radix-ui/react-switch \
        @radix-ui/react-dialog \
        @radix-ui/react-label

# Verify installation
print_status "Verifying installation..."
yarn tsc:write
yarn lint
yarn test

print_status "Running non-expo users setup..."
npx pod-install

print_status "Setup complete!"
print_status "⚠️  Important next steps:"
print_status "1. Change the default password in .env"
print_status "2. Follow react-native-reanimated setup guide:"
print_status "   https://docs.swmansion.com/react-native-reanimated/docs/fundamentals/getting-started/#step-2-add-reanimateds-babel-plugin"
print_status "3. Run 'yarn fresh' to start with a clean cache"