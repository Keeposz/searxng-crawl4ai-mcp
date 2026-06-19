FROM node:18-alpine

WORKDIR /app

# Install dependencies for Playwright
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Set Playwright to use system chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Enable pnpm via Corepack (bundled with Node 18)
RUN corepack enable && corepack prepare pnpm@11.3.0 --activate

# Copy manifest, lockfile and pnpm settings
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Install dependencies (reproducible from the committed lockfile)
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
RUN pnpm run build

# Expose port for MCP server
EXPOSE 3003

RUN chown -R 1000:1000 /app
USER 1000

# Start the MCP server
CMD ["pnpm", "start"]