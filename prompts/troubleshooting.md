# Troubleshooting Prompt for LAN Runner + Ollama

## Common Issues and Solutions

### Runner Registration Fails
- Check RUNNER_TOKEN is fresh (expires quickly)
- Verify REPO_URL or ORG_URL is correct (only one set)
- Ensure network connectivity to github.com
- Check docker compose logs github-runner

### Ollama Not Accessible
- Verify OLLAMA_HOST_PORT is not conflicted
- Check OLLAMA_HOST=0.0.0.0 is set
- Test with curl http://localhost:11434/api/tags
- Ensure firewall allows the port

### GPU Not Working
- Confirm NVIDIA drivers and container toolkit installed
- Set OLLAMA_GPU=all in .env
- Use GPU overlay: docker compose -f docker-compose.yml -f docker-compose.gpu.yml
- Check nvidia-smi in container

### Docker Sock Issues
- Ensure user in docker group
- Check permissions on /var/run/docker.sock
- Be aware of security implications
- Consider ARC for Kubernetes instead

### Performance Problems
- Monitor CPU/memory usage
- Check model sizes vs available RAM
- Consider lite overlay for resource constraints
- Verify network speed for model downloads

### Kubernetes Issues
- Check ARC installation
- Verify namespace and secrets
- Test with kubectl apply -k
- Check node labels for GPU

## Debugging Steps
1. Run ./test.sh for basic validation
2. Check docker compose ps for running services
3. Review logs: docker compose logs -f
4. Test individual components
5. Verify environment variables
6. Check host prerequisites

## Getting Help
- Check official docs first
- Review README.md troubleshooting section
- Test in isolated environment
- Document findings for future reference
- Refer to `../documentation-index.md` for complete reference mapping

## Workflow Notes
- Always commit fixes with GPG verification
- Update `../PROJECT.md` if issues reveal needed enhancements