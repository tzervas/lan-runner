# Development Prompt for LAN Runner + Ollama

When working on the LAN Runner + Ollama project, consider:

## Current State
- Docker Compose stack with GitHub runner and Ollama services
- CPU-optimized by default, GPU opt-in
- Environment-driven configuration
- Kubernetes support with ARC
- Comprehensive documentation and testing

## Development Guidelines
- Always reference official GitHub Actions and Ollama documentation
- Prioritize security and minimal resource usage
- Test changes thoroughly with docker compose and health checks
- Update all documentation files when making changes
- Keep configurations env-driven and portable

## Common Tasks
- Adding new environment variables: Update .env.example, docker-compose.yml, README.md
- Modifying services: Ensure compatibility with existing overlays (lite, gpu)
- Kubernetes changes: Test with multiple k8s distributions
- Documentation updates: Keep README.md, context.md, and copilot-instructions.md in sync

## Quality Checks
- Run test.sh after changes
- Verify docker compose up works
- Check logs for errors
- Test on different hardware if possible
- Update PROJECT.md with progress

## Documentation and Workflow
- Refer to `../documentation-index.md` for comprehensive reference mapping
- Always commit changes with GPG verification
- Sync all relevant documentation when making modifications