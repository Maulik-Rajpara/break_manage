# Contributing to Break Management App

We love your input! We want to make contributing to Break Management App as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We Develop with Github
We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## We Use [Github Flow](https://guides.github.com/introduction/flow/index.html)
We use GitHub Flow. So all code changes happen through Pull Requests.

## We Use [Conventional Commits](https://www.conventionalcommits.org/)
We use Conventional Commits for commit messages. This helps with automated changelog generation.

## Report bugs using Github's [issue tracker](https://github.com/yourusername/break_manage/issues)
We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/yourusername/break_manage/issues/new).

## Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can.
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## License
By contributing, you agree that your contributions will be licensed under its MIT License.

## References
This document was adapted from the open-source contribution guidelines for [Facebook's Draft](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md).

## Code Style

### Dart/Flutter
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use proper indentation (2 spaces)

### File Naming
- Use snake_case for file names
- Use descriptive names that indicate the purpose
- Group related files in appropriate directories

### Code Organization
- Follow the existing project structure
- Keep related code together
- Use proper separation of concerns
- Implement clean architecture principles

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass
6. Update documentation if needed
7. Commit your changes using conventional commits
8. Push to your branch (`git push origin feature/AmazingFeature`)
9. Open a Pull Request

## Commit Message Format

Use conventional commits format:

```
type(scope): description

[optional body]

[optional footer(s)]
```

Types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

Examples:
```
feat(auth): add biometric authentication
fix(dashboard): resolve break timer not updating
docs(readme): update installation instructions
```

## Testing

Before submitting a pull request, please ensure:

1. All existing tests pass
2. New tests are added for new functionality
3. Code coverage is maintained or improved
4. Manual testing is performed on both Android and iOS

## Review Process

1. All pull requests require at least one review
2. Maintainers will review your code
3. Address any feedback or requested changes
4. Once approved, your PR will be merged

## Getting Help

If you need help with contributing:

1. Check existing issues and pull requests
2. Join our community discussions
3. Contact the maintainers directly

Thank you for contributing to Break Management App! 🎉 