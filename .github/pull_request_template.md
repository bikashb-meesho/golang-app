## Description
<!-- Provide a brief description of the changes -->



## Library Dependency
<!-- IMPORTANT: For PRs to main branch -->

**Library Version Used**: 

- [ ] ✅ Using tagged version (vX.Y.Z) from main branch
- [ ] ✅ Removed `replace` directive from go.mod
- [ ] ⚠️ Using development version (feature branches only)

```bash
# Library version from go.mod:
github.com/bikashb-meesho/golang-lib v____
```

## Type of Change
<!-- Mark the relevant option with an 'x' -->

- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 💥 Breaking change
- [ ] 🔧 Configuration change
- [ ] 📝 Documentation update
- [ ] 🎨 Code style/refactoring
- [ ] ⚡ Performance improvement

## Changes Made
<!-- List the specific changes -->

- 
- 
- 

## Testing

### Unit Tests
- [ ] Unit tests added/updated
- [ ] All unit tests passing locally
- [ ] Integration tests passing

### Manual Testing
<!-- Describe how you manually tested these changes -->

**Test Environment**: 
- [ ] Local
- [ ] Staging
- [ ] Docker

**Test Steps**:
1. 
2. 
3. 

**Test Results**:
```bash
# Commands and output

```

## API Changes
<!-- If API endpoints changed, document them -->

### New Endpoints
- 

### Modified Endpoints
- 

### Deprecated Endpoints
- 

## Checklist

### Code Quality
- [ ] Code follows project style guidelines
- [ ] Code formatted with `go fmt`
- [ ] `go vet` passes without errors
- [ ] No new linting errors

### Dependencies
- [ ] `go.mod` and `go.sum` updated
- [ ] Dependencies verified with `go mod verify`
- [ ] `go mod tidy` executed
- [ ] No unnecessary dependencies added

### Documentation
- [ ] Code comments added where needed
- [ ] README updated (if needed)
- [ ] API documentation updated (if endpoints changed)

### Security
- [ ] No sensitive data in code
- [ ] Input validation added for user inputs
- [ ] Security best practices followed

## Deployment

### Target Environment
- [ ] Development
- [ ] Staging
- [ ] Production

### Deployment Notes
<!-- Special instructions for deployment -->



### Database Changes
- [ ] No database changes
- [ ] Database migration required
- [ ] Migration script included

### Configuration Changes
- [ ] No config changes
- [ ] Environment variables added/changed
- [ ] Config documentation updated

## Performance Impact
<!-- Describe any performance implications -->

- [ ] No performance impact
- [ ] Performance improved
- [ ] Performance degraded (explain why acceptable)

## Rollback Plan
<!-- How to rollback if issues arise after deployment -->

1. 
2. 

## Screenshots/Videos
<!-- If UI changes, add screenshots or videos -->



## Related Issues
<!-- Link to related issues -->

Closes #
Relates to #

## Additional Notes
<!-- Any additional context, decisions made, or follow-up tasks -->



---

**For Reviewers:**
- [ ] Code reviewed thoroughly
- [ ] Library version verified (main branch only)
- [ ] Tests verified locally
- [ ] Security considerations reviewed
- [ ] Documentation checked
- [ ] Ready for merge

