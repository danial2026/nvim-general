-- Commit Message Rules Configuration
-- ===================================
-- This file defines rules and templates for AI-generated commit messages
local M = {}

-- Commit message types (Conventional Commits)
M.types = {
    feat = {
        description = "A new feature",
        emoji = "✦",
        examples = {
            "feat: add user authentication", "feat(api): implement pagination",
            "feat(ui): dark mode toggle"
        }
    },
    fix = {
        description = "A bug fix",
        emoji = "✓",
        examples = {
            "fix: resolve memory leak in cache",
            "fix(api): handle null response",
            "fix(ui): button alignment on mobile"
        }
    },
    docs = {
        description = "Documentation only changes",
        emoji = "✎",
        examples = {
            "docs: update README", "docs(api): add endpoint documentation",
            "docs: fix typo in comments"
        }
    },
    style = {
        description = "Changes that do not affect the meaning of the code",
        emoji = "⋄",
        examples = {
            "style: format code with prettier", "style: fix linting errors",
            "style: improve code formatting"
        }
    },
    refactor = {
        description = "A code change that neither fixes a bug nor adds a feature",
        emoji = "↻",
        examples = {
            "refactor: extract utility functions",
            "refactor(api): simplify error handling",
            "refactor: improve code structure"
        }
    },
    perf = {
        description = "A code change that improves performance",
        emoji = "⚡",
        examples = {
            "perf: optimize database queries", "perf: reduce bundle size",
            "perf: improve rendering speed"
        }
    },
    test = {
        description = "Adding missing tests or correcting existing tests",
        emoji = "☑",
        examples = {
            "test: add unit tests for auth", "test: fix flaky integration test",
            "test: increase test coverage"
        }
    },
    build = {
        description = "Changes that affect the build system or external dependencies",
        emoji = "⊡",
        examples = {
            "build: update webpack configuration", "build: add new npm script",
            "build: upgrade dependencies"
        }
    },
    ci = {
        description = "Changes to CI configuration files and scripts",
        emoji = "⚙",
        examples = {
            "ci: add GitHub Actions workflow", "ci: fix deployment script",
            "ci: update docker configuration"
        }
    },
    chore = {
        description = "Other changes that don't modify src or test files",
        emoji = "∆",
        examples = {
            "chore: update .gitignore", "chore: add license file",
            "chore: cleanup project structure"
        }
    },
    revert = {
        description = "Reverts a previous commit",
        emoji = "↺",
        examples = {
            "revert: revert feature X", "revert(api): remove breaking change",
            "revert: undo merge commit"
        }
    }
}

-- Commit message templates
M.templates = {
    conventional = {
        pattern = "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\\(.+\\))?: .+",
        description = "Conventional Commits format",
        example = "feat(auth): add password reset functionality"
    },
    simple = {
        pattern = "^.+: .+",
        description = "Simple prefix format",
        example = "Add user profile page"
    },
    emoji = {
        pattern = "^:.*: .+",
        description = "Gitmoji format",
        example = ":sparkles: Add new feature"
    }
}

-- Language-specific rules
M.language_rules = {
    lua = {
        scope_prefix = "lua",
        common_scopes = {"config", "plugin", "module", "utils"},
        keywords = {"require", "module", "function", "table", "metatable"}
    },
    javascript = {
        scope_prefix = "js",
        common_scopes = {"api", "ui", "utils", "hooks", "components"},
        keywords = {"function", "component", "hook", "api", "state"}
    },
    typescript = {
        scope_prefix = "ts",
        common_scopes = {"api", "ui", "types", "utils", "components"},
        keywords = {"interface", "type", "generic", "component", "hook"}
    },
    go = {
        scope_prefix = "go",
        common_scopes = {"api", "handler", "model", "service", "utils"},
        keywords = {"func", "struct", "interface", "method", "goroutine"}
    },
    dart = {
        scope_prefix = "dart",
        common_scopes = {"widget", "provider", "bloc", "cubit", "service"},
        keywords = {"class", "widget", "state", "provider", "builder"}
    },
    python = {
        scope_prefix = "py",
        common_scopes = {"api", "model", "service", "utils", "tests"},
        keywords = {"def", "class", "async", "decorator", "import"}
    },
    rust = {
        scope_prefix = "rs",
        common_scopes = {"api", "model", "service", "error", "tests"},
        keywords = {"fn", "struct", "impl", "trait", "enum"}
    },
    java = {
        scope_prefix = "java",
        common_scopes = {
            "controller", "service", "repository", "model", "utils"
        },
        keywords = {"class", "method", "interface", "annotation", "spring"}
    }
}

-- File type to language mapping
M.filetype_to_language = {
    lua = "lua",
    javascript = "javascript",
    javascriptreact = "javascript",
    typescript = "typescript",
    typescriptreact = "typescript",
    go = "go",
    dart = "dart",
    python = "python",
    rust = "rust",
    java = "java",
    c = "c",
    cpp = "cpp",
    cs = "csharp",
    php = "php",
    ruby = "ruby",
    swift = "swift",
    kotlin = "kotlin",
    scala = "scala"
}

-- Commit message guidelines
M.guidelines = {
    max_length = 72,
    min_length = 10,
    imperative_mood = true,
    capitalize_first_letter = true,
    no_period_at_end = true,
    include_scope = true,
    include_emoji = false, -- Set to true for Gitmoji style
    include_body = true,
    include_footer = false,
    body_format = "bullet-point", -- Focus on bullet-point format for ONE amazing message
    max_body_length = 1000,
    include_file_summary = true,
    group_by_file_type = false, -- Each file gets its own bullet point section
    single_message_only = true -- Generate ONE amazing message only
}

-- AI prompt templates
M.ai_prompts = {
    generate = [[
You are an expert software engineer generating ONE amazing commit message.
Analyze the git diff and generate a SINGLE, PERFECT commit message.

**NON-NEGOTIABLE RULES:**
1. **Format**: type(scope): description (Conventional Commits)
2. **Types**: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
3. **Scope**: 2-10 chars describing affected area
4. **Description**: Imperative mood, under 72 chars, capitalize first letter, no period
5. **Body**: REQUIRED - detailed, bullet-point format, file-by-file organization

**BODY FORMAT (STRICT):**
- filename.ext
  * [Class/Function] Description of change with technical details
  * [Class/Function] Another change if applicable

**CONTEXT REQUIREMENTS:**
- For each change: Include class name, function/method name, or signature
- Be specific about what changed and why it matters
- Use technical precision

**QUALITY STANDARDS:**
- Must be production-ready
- Must accurately reflect ALL changes
- Must be clear enough for code review
- Must follow best practices for commit messages

**OUTPUT FORMAT:**
[Commit message subject]
[blank line]
[Body in exact format above]

**DO NOT:**
- Add explanations before/after
- Generate multiple options
- Skip the body
- Be vague or generic

8. After the subject line, include a detailed body separated by a blank line
9. In the body, organize changes by section/file type
10. For each section, list the specific changes made
11. Use bullet points for readability
12. Include context about why changes were made when relevant
13. Keep the body informative but concise

Git diff:
{{DIFF}}

Generate ONE amazing commit message:
]]
}

-- Validation rules
M.validation = {
    patterns = {
        conventional = "^%a+%(.*%): .+",
        simple = "^.+: .+",
        emoji = "^:.*: .+"
    },
    max_length = 72,
    min_length = 5,
    max_body_length = 1000,
    required_fields = {"type", "description"},
    body_required_for = {
        "feat", "fix", "refactor", "docs", "style", "perf", "test", "build",
        "ci", "chore"
    }
}

-- Helper functions
function M.get_language_for_filetype(filetype)
    return M.filetype_to_language[filetype] or "unknown"
end

function M.get_scope_suggestions(filetype, changed_files)
    local language = M.get_language_for_filetype(filetype)
    local rules = M.language_rules[language] or {}
    local suggestions = {}

    -- Add common scopes for the language
    if rules.common_scopes then
        for _, scope in ipairs(rules.common_scopes) do
            table.insert(suggestions, scope)
        end
    end

    -- Extract scopes from changed files
    for _, file in ipairs(changed_files) do
        local dir = file:match("^([^/]+)/")
        if dir and not vim.tbl_contains(suggestions, dir) then
            table.insert(suggestions, dir)
        end
    end

    return suggestions
end

function M.get_type_suggestions(changes)
    local suggestions = {}

    -- Analyze changes to suggest appropriate types
    local added = changes.added or 0
    local modified = changes.modified or 0
    local deleted = changes.deleted or 0

    if added > 0 then table.insert(suggestions, "feat") end

    if modified > 0 then
        table.insert(suggestions, "fix")
        table.insert(suggestions, "refactor")
    end

    if deleted > 0 then
        table.insert(suggestions, "refactor")
        table.insert(suggestions, "chore")
    end

    -- Always include common types
    local common = {"docs", "test", "style", "chore"}
    for _, type in ipairs(common) do
        if not vim.tbl_contains(suggestions, type) then
            table.insert(suggestions, type)
        end
    end

    return suggestions
end

function M.validate_commit_message(message)
    local errors = {}
    local warnings = {}

    -- Check length
    if #message > M.guidelines.max_length then
        table.insert(warnings,
                     string.format("Message is too long (%d > %d characters)",
                                   #message, M.guidelines.max_length))
    end

    if #message < M.guidelines.min_length then
        table.insert(errors,
                     string.format("Message is too short (%d < %d characters)",
                                   #message, M.guidelines.min_length))
    end

    -- Check format
    local valid = false
    for _, pattern in pairs(M.validation.patterns) do
        if message:match(pattern) then
            valid = true
            break
        end
    end

    if not valid then
        table.insert(errors, "Message doesn't match any known format")
    end

    -- Check for period at end
    if M.guidelines.no_period_at_end and message:sub(-1) == "." then
        table.insert(warnings, "Message ends with a period")
    end

    -- Check capitalization
    if M.guidelines.capitalize_first_letter then
        local first_char = message:sub(1, 1)
        if first_char ~= first_char:upper() then
            table.insert(warnings, "First letter should be capitalized")
        end
    end

    return {valid = #errors == 0, errors = errors, warnings = warnings}
end

function M.format_commit_message(type, scope, description, body, footer)
    local message = ""

    -- Add emoji if enabled
    if M.guidelines.include_emoji and M.types[type] and M.types[type].emoji then
        message = message .. M.types[type].emoji .. " "
    end

    -- Add type and scope
    if scope and scope ~= "" then
        message = message ..
                      string.format("%s(%s): %s", type, scope, description)
    else
        message = message .. string.format("%s: %s", type, description)
    end

    -- Add body if provided
    if M.guidelines.include_body and body and body ~= "" then
        message = message .. "\n\n" .. body
    end

    -- Add footer if provided
    if M.guidelines.include_footer and footer and footer ~= "" then
        message = message .. "\n\n" .. footer
    end

    return message
end

function M.get_examples_for_type(type)
    local type_info = M.types[type]
    if type_info then return type_info.examples or {} end
    return {}
end

function M.get_all_examples()
    local examples = {}
    for type_name, type_info in pairs(M.types) do
        if type_info.examples then
            for _, example in ipairs(type_info.examples) do
                table.insert(examples, {
                    type = type_name,
                    example = example,
                    emoji = type_info.emoji
                })
            end
        end
    end
    return examples
end

return M
