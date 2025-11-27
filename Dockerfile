FROM --platform=linux/amd64 node:18-slim

WORKDIR /usr/src/app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source files
COPY . .

# Build the application
RUN npm run build

# Expose the port (default 8080)
EXPOSE 8080

# Run the application
CMD ["node", "dist/main.js"]
