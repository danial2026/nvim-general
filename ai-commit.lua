-- AI Commit Message Generation Plugin
-- ====================================
-- Uses AI to generate commit messages based on git staged changes
-- Requires: curl, git
local M = {}

-- Configuration defaults
M.config = {
    api_key = os.getenv("DEEPSEEK_API_KEY") or "",
    api_url = "https://api.deepseek.com/v1/chat/completions",
    model = "deepseek-chat",
    max_tokens = 2000,
    temperature = 0.7,
    timeout = 30000, -- 30 seconds
    keymaps = {generate = "<leader>cg"},
    rules_file = vim.fn.stdpath("config") .. "/commit-rules.lua"
}

-- State
M.state = {staged_changes = nil, rules = nil}

-- Check if curl is available
local function check_curl()
    local result = vim.fn.system("which curl")
    return vim.v.shell_error == 0
end

-- Check if git is available
local function check_git()
    local result = vim.fn.system("which git")
    return vim.v.shell_error == 0
end

-- Load commit rules
function M.load_rules()
    -- First try to load language-specific rules file
    local language_specific_file = M.config.rules_file
    local general_file = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h") ..
                             "/nvim-general/commit-rules.lua"

    -- Debug logging for commit rules loading
    -- vim.notify("Looking for commit rules...", vim.log.levels.DEBUG)
    -- vim.notify("Language-specific file: " .. language_specific_file, vim.log.levels.DEBUG)
    -- vim.notify("General file: " .. general_file, vim.log.levels.DEBUG)

    local rules_file = nil
    local file_type = nil

    -- Check if language-specific file exists
    if vim.fn.filereadable(language_specific_file) == 1 then
        rules_file = language_specific_file
        file_type = "language-specific"
        -- vim.notify("Found language-specific commit rules file: " .. rules_file, vim.log.levels.DEBUG)
        -- Fall back to general file
    elseif vim.fn.filereadable(general_file) == 1 then
        rules_file = general_file
        file_type = "general"
        -- vim.notify("Using general commit rules file", vim.log.levels.DEBUG)
    else
        vim.notify("No commit rules file found. Using built-in defaults.",
                   vim.log.levels.WARN)
        -- vim.notify("Language-specific file not found: " .. language_specific_file, vim.log.levels.DEBUG)
        -- vim.notify("General file not found: " .. general_file, vim.log.levels.DEBUG)
        M.state.rules = M.get_default_rules()
        vim.notify("Using built-in default commit rules", vim.log.levels.INFO)
        return true
    end

    -- Read and execute the file
    local content = vim.fn.readfile(rules_file)
    if not content or #content == 0 then
        vim.notify("Commit rules file is empty: " .. rules_file,
                   vim.log.levels.ERROR)
        return false
    end

    -- Create a temporary function to load the module
    local chunk = loadstring(table.concat(content, "\n"), rules_file)
    if not chunk then
        vim.notify("Failed to parse commit rules file: " .. rules_file,
                   vim.log.levels.ERROR)
        return false
    end

    local ok, rules = pcall(chunk)
    if ok and rules then
        M.state.rules = rules
        -- vim.notify("Commit rules loaded successfully from " .. file_type .. " file", vim.log.levels.DEBUG)
        return true
    else
        local err_msg = "Failed to load commit rules from " .. rules_file
        if not ok then err_msg = err_msg .. ": " .. tostring(rules) end
        vim.notify(err_msg, vim.log.levels.ERROR)
        return false
    end
end

-- Get default commit rules when no rules file is found
function M.get_default_rules()
    return {
        types = {
            feat = {
                description = "A new feature",
                emoji = "✦",
                examples = {
                    "feat: add new feature", "feat(api): implement endpoint",
                    "feat(ui): add component"
                }
            },
            fix = {
                description = "A bug fix",
                emoji = "✓",
                examples = {
                    "fix: resolve issue", "fix(api): handle error",
                    "fix(ui): correct alignment"
                }
            },
            docs = {
                description = "Documentation only changes",
                emoji = "✎",
                examples = {
                    "docs: update README", "docs: add comments",
                    "docs: fix typos"
                }
            },
            style = {
                description = "Code style changes",
                emoji = "⋄",
                examples = {
                    "style: format code", "style: fix linting",
                    "style: improve formatting"
                }
            },
            refactor = {
                description = "Code refactoring",
                emoji = "↻",
                examples = {
                    "refactor: extract function", "refactor: simplify logic",
                    "refactor: improve structure"
                }
            },
            test = {
                description = "Test changes",
                emoji = "☑",
                examples = {
                    "test: add unit test", "test: fix test",
                    "test: increase coverage"
                }
            },
            chore = {
                description = "Maintenance tasks",
                emoji = "∆",
                examples = {
                    "chore: update dependencies", "chore: cleanup code",
                    "chore: add configuration"
                }
            }
        },
        guidelines = {
            max_length = 72,
            min_length = 10,
            imperative_mood = true,
            capitalize_first_letter = true,
            no_period_at_end = true,
            include_scope = true,
            include_emoji = false,
            include_body = true,
            include_footer = false,
            body_format = "sectioned",
            max_body_length = 1000,
            include_file_summary = true,
            group_by_file_type = true
        },
        validation = {
            patterns = {
                conventional = "^%a+%(.*%): .+",
                simple = "^.+: .+",
                emoji = "^:.*: .+"
            },
            max_length = 72,
            min_length = 5,
            max_body_length = 1000,
            required_fields = {"type", "description"},
            body_required_for = {"feat", "fix", "refactor"}
        },
        ai_prompts = {
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

Git diff:
{{DIFF}}

Generate ONE amazing commit message:
]],
            validate_commit_message = function(message)
                local errors = {}
                local warnings = {}
                local default_rules = {
                    guidelines = {
                        max_length = 72,
                        min_length = 10,
                        no_period_at_end = true,
                        capitalize_first_letter = true
                    },
                    validation = {
                        patterns = {
                            conventional = "^%a+%(.*%): .+",
                            simple = "^.+: .+",
                            emoji = "^:.*: .+"
                        }
                    }
                }

                -- Check length
                if #message > default_rules.guidelines.max_length then
                    table.insert(warnings,
                                 string.format(
                                     "Message is too long (%d > %d characters)",
                                     #message,
                                     default_rules.guidelines.max_length))
                end

                if #message < default_rules.guidelines.min_length then
                    table.insert(errors,
                                 string.format(
                                     "Message is too short (%d < %d characters)",
                                     #message,
                                     default_rules.guidelines.min_length))
                end

                -- Check format
                local valid = false
                for _, pattern in pairs(default_rules.validation.patterns) do
                    if message:match(pattern) then
                        valid = true
                        break
                    end
                end

                if not valid then
                    table.insert(errors,
                                 "Message doesn't match any known format")
                end

                -- Check for period at end
                if default_rules.guidelines.no_period_at_end and message:sub(-1) ==
                    "." then
                    table.insert(warnings, "Message ends with a period")
                end

                -- Check capitalization
                if default_rules.guidelines.capitalize_first_letter then
                    local first_char = message:sub(1, 1)
                    if first_char ~= first_char:upper() then
                        table.insert(warnings,
                                     "First letter should be capitalized")
                    end
                end

                return {
                    valid = #errors == 0,
                    errors = errors,
                    warnings = warnings
                }
            end
        }
    }
end

-- Get git staged changes
function M.get_staged_changes()
    local result = vim.fn.system("git diff --cached --stat")
    if vim.v.shell_error ~= 0 then
        return nil, "Not a git repository or no staged changes"
    end

    if result == "" then return nil, "No staged changes" end

    -- Get detailed diff with better options
    -- Use --no-color to remove ANSI codes, and --no-ext-diff for consistent output
    local diff = vim.fn.system("git diff --cached --no-color --no-ext-diff")
    if vim.v.shell_error ~= 0 then return nil, "Failed to get detailed diff" end

    -- Also get diff with context for better AI understanding
    local diff_with_context = vim.fn.system(
                                  "git diff --cached --no-color --no-ext-diff --unified=3")
    local diff_context = diff_with_context
    if vim.v.shell_error ~= 0 then
        diff_context = diff -- Fall back to regular diff if context diff fails
    end

    -- Parse file changes with more detail
    local files = {}
    local file_types = {}
    local changes_by_type = {}

    -- Get list of changed files for summary
    local changed_files_list = vim.fn.system("git diff --cached --name-only")
    local changed_files = {}
    if changed_files_list and changed_files_list ~= "" then
        for file in changed_files_list:gmatch("[^\n]+") do
            table.insert(changed_files, file)
        end
    end

    for line in result:gmatch("[^\n]+") do
        -- Skip summary line
        if not line:match("^%s*%d+ files? changed") then
            local file_match = line:match("([^|]+)|")
            if file_match then
                local file = file_match:gsub("^%s+", ""):gsub("%s+$", "")
                -- Parse additions and deletions with more flexible regex
                -- Handle formats like: "10 insertions(+), 5 deletions(-)" or "15 deletions(-)"
                local additions_str = line:match("(%d+) insertions?%(%+%)")
                local deletions_str = line:match("(%d+) deletions?%(%-%)")

                local additions = additions_str and tonumber(additions_str) or 0
                local deletions = deletions_str and tonumber(deletions_str) or 0

                -- For binary files or files without insertions/deletions markers,
                -- check if there are actual + or - characters in the stats column
                if additions == 0 and deletions == 0 then
                    -- Look at the stats column (after the |)
                    local stats_part = line:match("|%s*(.+)$")
                    if stats_part then
                        -- Count only + and - that are not part of "insertions(+)" or "deletions(-)"
                        -- These would be in the visual representation of changes
                        local visual_plus = 0
                        local visual_minus = 0
                        for char in stats_part:gmatch("[+%-]") do
                            if char == "+" then
                                visual_plus = visual_plus + 1
                            elseif char == "-" then
                                visual_minus = visual_minus + 1
                            end
                        end
                        additions = visual_plus
                        deletions = visual_minus
                    end
                end

                -- Get file extension/type
                local file_type = "unknown"
                local extension = file:match("%.(%w+)$")
                if extension then
                    file_type = extension
                elseif file:match("/$") then
                    file_type = "directory"
                end

                -- Group by file type
                if not changes_by_type[file_type] then
                    changes_by_type[file_type] = {
                        files = {},
                        total_additions = 0,
                        total_deletions = 0,
                        count = 0
                    }
                end

                table.insert(changes_by_type[file_type].files, file)
                changes_by_type[file_type].total_additions =
                    changes_by_type[file_type].total_additions + additions
                changes_by_type[file_type].total_deletions =
                    changes_by_type[file_type].total_deletions + deletions
                changes_by_type[file_type].count =
                    changes_by_type[file_type].count + 1

                table.insert(files, {
                    name = file,
                    type = file_type,
                    additions = additions,
                    deletions = deletions,
                    changes = additions + deletions
                })

                if not vim.tbl_contains(file_types, file_type) then
                    table.insert(file_types, file_type)
                end
            end
        end
    end

    -- Count changes more accurately
    local added = 0
    local modified = 0
    local deleted = 0
    local in_hunk = false

    for line in diff:gmatch("[^\n]+") do
        if line:match("^%+%+%+") then
            -- File header
            in_hunk = false
        elseif line:match("^%-%-%-") then
            -- File header
            in_hunk = false
        elseif line:match("^@@") then
            -- Hunk header
            in_hunk = true
            modified = modified + 1
        elseif in_hunk then
            if line:match("^%+") then
                -- Added line
                added = added + 1
            elseif line:match("^-") then
                -- Removed line
                deleted = deleted + 1
            end
        end
    end

    -- Get file type statistics
    local file_type_stats = {}
    for file_type, data in pairs(changes_by_type) do
        table.insert(file_type_stats, {
            type = file_type,
            file_count = data.count,
            additions = data.total_additions,
            deletions = data.total_deletions,
            total_changes = data.total_additions + data.total_deletions,
            files = data.files
        })
    end

    -- Sort by total changes
    table.sort(file_type_stats,
               function(a, b) return a.total_changes > b.total_changes end)

    M.state.staged_changes = {
        summary = result,
        diff = diff,
        diff_with_context = diff_context,
        changed_files = changed_files,
        files = files,
        file_types = file_types,
        file_type_stats = file_type_stats,
        stats = {
            added = added,
            modified = modified,
            deleted = deleted,
            total = added + modified + deleted,
            file_count = #files,
            changed_file_count = #changed_files
        }
    }

    return M.state.staged_changes
end

-- Create a summarized diff for large changes
function M.create_diff_summary(changes)
    local summary_lines = {}

    table.insert(summary_lines, "=== Git Diff Summary ===")
    table.insert(summary_lines, "")
    table.insert(summary_lines,
                 "Total files changed: " .. changes.stats.changed_file_count)
    table.insert(summary_lines, "Total lines changed: " .. changes.stats.total)
    table.insert(summary_lines, "Additions: " .. changes.stats.added)
    table.insert(summary_lines, "Deletions: " .. changes.stats.deleted)
    table.insert(summary_lines, "")

    if changes.file_type_stats and #changes.file_type_stats > 0 then
        table.insert(summary_lines, "=== Changes by File Type ===")
        table.insert(summary_lines, "")
        for _, type_stat in ipairs(changes.file_type_stats) do
            if type_stat.total_changes > 0 then
                table.insert(summary_lines,
                             string.format("%s: %d files, %+d -%d lines",
                                           type_stat.type, type_stat.file_count,
                                           type_stat.additions,
                                           type_stat.deletions))
            end
        end
        table.insert(summary_lines, "")
    end

    table.insert(summary_lines, "=== Changed Files ===")
    table.insert(summary_lines, "")
    for i, file in ipairs(changes.changed_files) do
        if i <= 50 then -- Limit to 50 files in summary
            table.insert(summary_lines, file)
        elseif i == 51 then
            table.insert(summary_lines, "... and " ..
                             (#changes.changed_files - 50) .. " more files")
        end
    end
    table.insert(summary_lines, "")

    table.insert(summary_lines, "=== Sample Diff (first 8000 chars) ===")
    table.insert(summary_lines, "")

    -- Include a sample of the actual diff
    local sample_diff = changes.diff_with_context or changes.diff
    if #sample_diff > 8000 then
        sample_diff = sample_diff:sub(1, 8000) ..
                          "\n... (diff truncated due to size)"
    end
    table.insert(summary_lines, sample_diff)

    return table.concat(summary_lines, "\n")
end

-- Call AI API using curl
function M.call_ai_api(prompt)
    if M.config.api_key == "" then
        return nil,
               "API key not set. Set DEEPSEEK_API_KEY environment variable."
    end

    -- Create temporary file for request
    local temp_file = os.tmpname()
    local request_body = string.format([[
{
    "model": "%s",
    "messages": [
        {
            "role": "user",
            "content": %s
        }
    ],
    "max_tokens": %d,
    "temperature": %f,
    "stream": false
}
]], M.config.model, vim.fn.json_encode(prompt), M.config.max_tokens,
                                       M.config.temperature)

    -- Write request to temp file
    local file = io.open(temp_file, "w")
    if not file then return nil, "Failed to create temporary file" end
    file:write(request_body)
    file:close()

    -- Make API call with curl
    local curl_cmd = string.format('curl -s -X POST "%s" ' ..
                                       '-H "Content-Type: application/json" ' ..
                                       '-H "Authorization: Bearer %s" ' ..
                                       '--data @"%s"', M.config.api_url,
                                   M.config.api_key, temp_file)

    local result = vim.fn.system(curl_cmd)
    local exit_code = vim.v.shell_error

    -- Clean up temp file
    os.remove(temp_file)

    if exit_code ~= 0 then
        return nil,
               "API request failed with curl exit code " .. tostring(exit_code) ..
                   ": " .. result
    end

    -- Parse JSON response
    local ok, response = pcall(vim.fn.json_decode, result)
    if not ok then return nil, "Failed to parse API response: " .. result end

    if response and response.choices and #response.choices > 0 then
        -- Extract token usage information if available
        local token_info = {}
        if response.usage then
            token_info = {
                prompt_tokens = response.usage.prompt_tokens or 0,
                completion_tokens = response.usage.completion_tokens or 0,
                total_tokens = response.usage.total_tokens or 0
            }
        end

        -- Return API details including request and full response
        local api_details = {
            request = {
                model = M.config.model,
                prompt = prompt,
                max_tokens = M.config.max_tokens,
                temperature = M.config.temperature,
                request_body = request_body
            },
            response = response,
            raw_response = result,
            curl_command = curl_cmd
        }

        return response.choices[1].message.content, nil, token_info, api_details
    else
        return nil, "No response from AI: " .. result
    end
end

-- Generate ONE amazing AI commit message
function M.generate_ai_message()
    vim.notify("Generating ONE amazing commit message...", vim.log.levels.INFO)

    -- Check if git is available
    if not check_git() then
        vim.notify(
            "git is not installed. Please install git to use AI commit features.",
            vim.log.levels.ERROR)
        return
    end

    local changes, err = M.get_staged_changes()
    if not changes then
        vim.notify(err, vim.log.levels.ERROR)
        return
    end

    -- Load rules if not loaded
    if not M.state.rules then
        if not M.load_rules() then
            vim.notify("Cannot generate AI message without commit rules",
                       vim.log.levels.ERROR)
            return
        end
    end

    -- Build prompt for ONE amazing message
    local rules = M.state.rules or {}
    local prompt = rules.ai_prompts.generate

    -- Get full diff without truncation
    local full_diff = changes.diff
    local max_diff_size = 12000

    if #full_diff > max_diff_size then
        vim.notify("Diff is large (" .. #full_diff ..
                       " chars). Using summarized diff.", vim.log.levels.WARN)
        local diff_summary = M.create_diff_summary(changes)
        prompt = prompt:gsub("{{DIFF}}", diff_summary)
    else
        prompt = prompt:gsub("{{DIFF}}", full_diff)
    end

    -- Check if curl is available
    if not check_curl() then
        vim.notify(
            "curl is not installed. Please install curl to use AI commit features.",
            vim.log.levels.ERROR)
        return
    end

    vim.notify("Generating commit message...", vim.log.levels.INFO)

    -- Create thinking window
    local thinking_win = M.create_thinking_window()

    -- Enhance prompt with file summary
    local enhanced_prompt = prompt
    if changes.file_type_stats and #changes.file_type_stats > 0 then
        local file_summary =
            "\n\nCHANGED FILES (create ONE amazing commit for these):\n"
        for _, type_stat in ipairs(changes.file_type_stats) do
            if type_stat.total_changes > 0 then
                file_summary = file_summary ..
                                   string.format("\n%s files (%d files):\n",
                                                 type_stat.type:upper(),
                                                 type_stat.file_count)
                for _, file in ipairs(type_stat.files) do
                    file_summary = file_summary ..
                                       string.format("  * %s\n", file)
                end
            end
        end
        enhanced_prompt =
            prompt:gsub("Git diff:", file_summary .. "\nGit diff:")
    end

    local start_time = vim.loop.hrtime()
    local response, err, token_info, api_details =
        M.call_ai_api(enhanced_prompt)
    local response_time = (vim.loop.hrtime() - start_time) / 1e9

    -- Close thinking window
    if thinking_win and thinking_win.win_id and
        vim.api.nvim_win_is_valid(thinking_win.win_id) then
        vim.api.nvim_win_close(thinking_win.win_id, true)
    end
    if not response then
        vim.notify("Failed to generate AI message: " .. err,
                   vim.log.levels.ERROR)
        return
    end

    -- Parse for ONE amazing message
    local ai_generated_message = {}
    local lines = vim.split(response, "\n")

    -- Find the commit message (should be first line or after empty intro)
    local message_line = nil
    local body_start = nil

    for i, line in ipairs(lines) do
        if line:match("^%a+%(.*%):") then
            message_line = line
            body_start = i + 1
            break
        end
    end

    -- If no conventional commit found, take first non-empty line as message
    if not message_line then
        for i, line in ipairs(lines) do
            if line:match("%S") then
                message_line = line
                body_start = i + 1
                break
            end
        end
    end

    if message_line then
        local body_lines = {}
        if body_start then
            for i = body_start, #lines do
                table.insert(body_lines, lines[i])
            end
        end

        -- Join body
        local body = table.concat(body_lines, "\n")
        body = body:gsub("^%s+", ""):gsub("%s+$", "")

        table.insert(ai_generated_message,
                     {number = 1, message = message_line, body = body})
    end

    if #ai_generated_message == 0 then
        vim.notify("Could not parse AI response", vim.log.levels.ERROR)
        return
    end

    -- Validate the message is amazing
    local message = ai_generated_message[1]
    if not message.body or message.body == "" then
        vim.notify("AI generated incomplete message (missing body). Try again.",
                   vim.log.levels.WARN)
        return
    end

    -- Save and show
    local saved_file = M.save_ai_message_to_file(ai_generated_message, changes,
                                                 api_details, response_time,
                                                 token_info, true)
    M.show_ai_message_in_new_tab(ai_generated_message, changes, response_time,
                                 token_info, api_details, saved_file)
end

-- Show AI-generated message in a popup (kept for backward compatibility)

-- Use a suggestion

-- Create a floating window to show AI is thinking
function M.create_thinking_window()
    local width = 40
    local height = 5
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded"
    })

    local lines = {
        "AI is thinking...", "",
        "Analyzing " .. M.state.staged_changes.stats.file_count .. " files",
        string.format("with %d total changes",
                      M.state.staged_changes.stats.total), "",
        "This may take a moment..."
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "readonly", true)

    -- Center align text
    vim.api.nvim_win_set_option(win_id, "winhl", "Normal:NormalFloat")
    vim.api.nvim_win_set_option(win_id, "winblend", 10)

    return {buf = buf, win_id = win_id}
end

-- Show AI-generated message in a new tab instead of popup
function M.show_ai_message_in_new_tab(ai_generated_message, changes,
                                      response_time, token_info, api_details,
                                      saved_file)
    -- Create a new tab
    vim.cmd("tabnew")
    local win_id = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_win_set_buf(win_id, buf)

    local lines = {
        "--- API Response Info ---",
        string.format("  Response time: %.2f seconds", response_time or 0),
        string.format("  Model: %s",
                      api_details and api_details.request.model or "unknown"),
        string.format("  Temperature: %.2f",
                      api_details and api_details.request.temperature or 0),
        string.format("  Max tokens: %d",
                      api_details and api_details.request.max_tokens or 0)
    }

    -- Add token usage information if available
    if token_info then
        if token_info.prompt_tokens then
            table.insert(lines, string.format("  Prompt tokens: %d",
                                              token_info.prompt_tokens))
        end
        if token_info.completion_tokens then
            table.insert(lines, string.format("  Completion tokens: %d",
                                              token_info.completion_tokens))
        end
        if token_info.total_tokens then
            table.insert(lines, string.format("  Total tokens: %d",
                                              token_info.total_tokens))
        end
    end

    table.insert(lines, "")
    table.insert(lines, "--- Staged Changes Summary ---")
    table.insert(lines,
                 string.format("  Files changed: %d", changes.stats.file_count))
    table.insert(lines,
                 string.format("  Total changes: %d", changes.stats.total))
    table.insert(lines, string.format("  Additions: %d", changes.stats.added))
    table.insert(lines, string.format("  Deletions: %d", changes.stats.deleted))
    table.insert(lines, "")

    -- Add file type summary
    if changes.file_type_stats and #changes.file_type_stats > 0 then
        table.insert(lines, "--- Files by Type ---")
        for _, type_stat in ipairs(changes.file_type_stats) do
            if type_stat.total_changes > 0 then
                table.insert(lines,
                             string.format("  %s: %d files, %+d -%d lines",
                                           type_stat.type, type_stat.file_count,
                                           type_stat.additions,
                                           type_stat.deletions))
            end
        end
        table.insert(lines, "")
    end

    table.insert(lines, "--- AI Generated Message ---")
    table.insert(lines, "")

    if #ai_generated_message > 0 then
        local ai_message = ai_generated_message[1]
        table.insert(lines, "📝 " .. ai_message.message)
        table.insert(lines, "")

        if ai_message.body and ai_message.body ~= "" then
            table.insert(lines, "DETAILED BODY:")
            table.insert(lines, "")

            local body_preview = ai_message.body
            local body_lines = vim.split(body_preview, "\n")
            local has_content = false

            for _, body_line in ipairs(body_lines) do
                local clean_line = body_line:gsub("\r", "")
                if clean_line:match("%S") then
                    table.insert(lines, "" .. clean_line)
                    has_content = true
                elseif has_content then
                    table.insert(lines, "")
                end
            end
        else
            table.insert(lines,
                         "⚠️  No body generated - message may be incomplete")
        end
        table.insert(lines, "")
    end

    table.insert(lines, "--- ACTIONS ---")
    table.insert(lines, "  [d] View API details")
    if saved_file then
        table.insert(lines, "  [e] Edit saved file: " .. saved_file)
    else
        table.insert(lines, "  [s] Save to file")
    end
    table.insert(lines, "  [q] Close tab")
    table.insert(lines, "")

    -- Ensure all lines are clean (no newlines)
    local clean_lines = {}
    for _, line in ipairs(lines) do
        local clean_line = line:gsub("[\r\n]", "")
        table.insert(clean_lines, clean_line)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, clean_lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_option(buf, "readonly", false) -- Allow user to edit/delete AI-generated messages

    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        callback = function() vim.cmd("tabclose") end,
        noremap = true,
        silent = true,
        desc = "Close AI messages tab"
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
        callback = function() vim.cmd("tabclose") end,
        noremap = true,
        silent = true,
        desc = "Close AI messages tab"
    })

    -- Add keymap for viewing API details
    vim.api.nvim_buf_set_keymap(buf, "n", "d", "", {
        callback = function()
            M.show_api_details(api_details, ai_generated_message, changes,
                               response_time, token_info)
        end,
        noremap = true,
        silent = true,
        desc = "Show API request/response details"
    })

    -- Add keymap for saving AI-generated message to file
    if saved_file then
        vim.api.nvim_buf_set_keymap(buf, "n", "e", "", {
            callback = function()
                vim.cmd("edit " .. vim.fn.fnameescape(saved_file))
            end,
            noremap = true,
            silent = true,
            desc = "Edit saved AI-generated message file"
        })
    else
        vim.api.nvim_buf_set_keymap(buf, "n", "s", "", {
            callback = function()
                M.save_ai_message_to_file(ai_generated_message, changes,
                                          api_details, response_time, token_info)
            end,
            noremap = true,
            silent = true,
            desc = "Save AI-generated message to file for editing"
        })
    end

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    -- Set window options
    vim.api.nvim_win_set_option(win_id, "winhl", "Normal:NormalFloat")
    vim.api.nvim_win_set_option(win_id, "cursorline", false)

    -- Store window reference
    M.state.ai_messages_panel = {win_id = win_id, buf = buf}

    -- Add a note that user can edit the buffer
    vim.defer_fn(function()
        vim.notify(
            "AI-generated messages opened in new tab. You can edit/delete text in the buffer.",
            vim.log.levels.INFO)
    end, 100)
end

-- Show API request/response details
function M.show_api_details(api_details, ai_generated_message, changes,
                            response_time, token_info)
    if not api_details then
        vim.notify("No API details available", vim.log.levels.WARN)
        return
    end

    -- Create a new buffer for API details
    local buf = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.8)) / 2),
        col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.8)) / 2),
        style = "minimal",
        border = "rounded"
    })

    local lines = {
        "=== AI Commit API Details ===", "", "--- Request Information ---",
        string.format("Model: %s", api_details.request.model),
        string.format("Temperature: %.2f", api_details.request.temperature),
        string.format("Max tokens: %d", api_details.request.max_tokens),
        string.format("Response time: %.2f seconds", response_time), "",
        "--- Token Usage ---"
    }

    if token_info then
        if token_info.prompt_tokens then
            table.insert(lines, string.format("Prompt tokens: %d",
                                              token_info.prompt_tokens))
        end
        if token_info.completion_tokens then
            table.insert(lines, string.format("Completion tokens: %d",
                                              token_info.completion_tokens))
        end
        if token_info.total_tokens then
            table.insert(lines, string.format("Total tokens: %d",
                                              token_info.total_tokens))
        end
    end

    table.insert(lines, "")
    table.insert(lines, "--- Request Body ---")
    table.insert(lines, "")

    -- Add request body with line numbers
    local request_lines = vim.split(api_details.request.request_body, "\n")
    for i, line in ipairs(request_lines) do
        table.insert(lines, string.format("%3d: %s", i, line))
    end

    table.insert(lines, "")
    table.insert(lines, "--- Full API Response ---")
    table.insert(lines, "")

    -- Add full response (truncated if too long)
    local response_text = vim.fn.json_encode(api_details.response)
    local response_lines = vim.split(response_text, "\n")
    local max_lines = 50

    if #response_lines > max_lines then
        for i = 1, max_lines do table.insert(lines, response_lines[i]) end
        table.insert(lines, string.format("... (truncated, %d more lines)",
                                          #response_lines - max_lines))
    else
        for _, line in ipairs(response_lines) do
            table.insert(lines, line)
        end
    end

    table.insert(lines, "")
    table.insert(lines, "--- Suggestions Summary ---")
    table.insert(lines, string.format("Number of AI-generated messages: %d",
                                      #ai_generated_message))
    table.insert(lines,
                 string.format("Files changed: %d", changes.stats.file_count))
    table.insert(lines, string.format("Total changes: %d", changes.stats.total))
    table.insert(lines, "")
    table.insert(lines, "--- Usage ---")
    table.insert(lines, "Press 'q' or 'Esc' to close this window")
    table.insert(lines, "Press 's' to save full details to file")

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "filetype", "json")

    -- Set up keymaps
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        callback = function() vim.api.nvim_win_close(win_id, true) end,
        noremap = true,
        silent = true,
        desc = "Close API details"
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
        callback = function() vim.api.nvim_win_close(win_id, true) end,
        noremap = true,
        silent = true,
        desc = "Close API details"
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "s", "", {
        callback = function()
            vim.api.nvim_win_close(win_id, true)
            M.save_api_details_to_file(api_details, ai_generated_message,
                                       changes, response_time, token_info)
        end,
        noremap = true,
        silent = true,
        desc = "Save API details to file"
    })
end

-- Save AI-generated messages to file for editing
function M.save_ai_message_to_file(ai_generated_message, changes, api_details,
                                   response_time, token_info, auto_save)
    -- Get git root directory
    local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
    git_root = git_root:gsub("%s+$", "")

    if git_root == "" or vim.v.shell_error ~= 0 then
        vim.notify("Not in a git repository", vim.log.levels.ERROR)
        return nil
    end

    -- Create .git/ai-commit-suggestions directory if it doesn't exist
    local suggestions_dir = git_root .. "/.git/ai-commit-suggestions"
    if vim.fn.isdirectory(suggestions_dir) == 0 then
        vim.fn.mkdir(suggestions_dir, "p")
    end

    -- Generate filename with timestamp
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local filename =
        suggestions_dir .. "/ai-generated-messages_" .. timestamp .. ".txt"

    -- Create file content in plain text format
    local content = {}

    table.insert(content, "AI GENERATED MESSAGE")
    table.insert(content, string.rep("=", 40))
    table.insert(content, "")
    table.insert(content, "Generated: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(content, "Response time: " ..
                     string.format("%.2f seconds", response_time))
    table.insert(content, "")

    if token_info then
        table.insert(content, "TOKEN USAGE")
        table.insert(content, string.rep("-", 20))
        if token_info.prompt_tokens then
            table.insert(content, "Prompt tokens: " .. token_info.prompt_tokens)
        end
        if token_info.completion_tokens then
            table.insert(content,
                         "Completion tokens: " .. token_info.completion_tokens)
        end
        if token_info.total_tokens then
            table.insert(content, "Total tokens: " .. token_info.total_tokens)
        end
        table.insert(content, "")
    end

    table.insert(content, "STAGED CHANGES")
    table.insert(content, string.rep("-", 20))
    table.insert(content, "Files changed: " .. changes.stats.file_count)
    table.insert(content, "Total changes: " .. changes.stats.total)
    table.insert(content, "Additions: " .. changes.stats.added)
    table.insert(content, "Deletions: " .. changes.stats.deleted)
    table.insert(content, "")

    if changes.file_type_stats and #changes.file_type_stats > 0 then
        table.insert(content, "FILES BY TYPE")
        table.insert(content, string.rep("-", 20))
        for _, type_stat in ipairs(changes.file_type_stats) do
            if type_stat.total_changes > 0 then
                table.insert(content,
                             string.format("%s: %d files, %+d -%d lines",
                                           type_stat.type, type_stat.file_count,
                                           type_stat.additions,
                                           type_stat.deletions))
            end
        end
        table.insert(content, "")
    end

    table.insert(content, "AI-GENERATED MESSAGE")
    table.insert(content, string.rep("-", 20))
    table.insert(content, "")

    if #ai_generated_message > 0 then
        local ai_message = ai_generated_message[1]
        table.insert(content, "Subject: " .. ai_message.message)
        table.insert(content, "")

        if ai_message.body and ai_message.body ~= "" then
            table.insert(content, "Body (bullet-point format by file):")
            table.insert(content, "")
            -- Add body content with proper line breaks
            local body_lines = vim.split(ai_message.body, "\n")
            for _, line in ipairs(body_lines) do
                -- Add all lines including empty ones to preserve formatting
                table.insert(content, "  " .. line)
            end
        else
            table.insert(content, "(No body provided)")
        end

        table.insert(content, "")
        table.insert(content, string.rep("-", 40))
        table.insert(content, "")
    end

    table.insert(content, "API DETAILS")
    table.insert(content, string.rep("-", 20))
    table.insert(content, "")
    table.insert(content, "Request:")
    table.insert(content, "")
    table.insert(content, api_details.request.request_body)
    table.insert(content, "")
    table.insert(content, "")
    table.insert(content, "Response:")
    table.insert(content, "")
    local response_json = vim.fn.json_encode(api_details.response)
    table.insert(content, response_json)

    -- Write to file
    local file = io.open(filename, "w")
    if file then
        file:write(table.concat(content, "\n"))
        file:close()

        if not auto_save then
            vim.notify("AI-generated message saved to: " .. filename,
                       vim.log.levels.INFO)
            -- Open the file for editing
            vim.cmd("edit " .. vim.fn.fnameescape(filename))
        end

        return filename
    else
        vim.notify("Failed to save AI-generated message to file",
                   vim.log.levels.ERROR)
        return nil
    end
end

-- Save API details to file
function M.save_api_details_to_file(api_details, ai_generated_message, changes,
                                    response_time, token_info)
    -- Get git root directory
    local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
    git_root = git_root:gsub("%s+$", "")

    if git_root == "" or vim.v.shell_error ~= 0 then
        vim.notify("Not in a git repository", vim.log.levels.ERROR)
        return
    end

    -- Create .git/ai-commit-suggestions directory if it doesn't exist
    local suggestions_dir = git_root .. "/.git/ai-commit-suggestions"
    if vim.fn.isdirectory(suggestions_dir) == 0 then
        vim.fn.mkdir(suggestions_dir, "p")
    end

    -- Generate filename with timestamp
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local filename = suggestions_dir .. "/api_details_" .. timestamp .. ".json"

    -- Create complete API details object
    local complete_details = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        response_time = response_time,
        token_info = token_info,
        changes = {
            file_count = changes.stats.file_count,
            total_changes = changes.stats.total,
            additions = changes.stats.added,
            deletions = changes.stats.deleted,
            file_type_stats = changes.file_type_stats
        },
        ai_generated_message = ai_generated_message,
        api_request = api_details.request,
        api_response = api_details.response,
        raw_response = api_details.raw_response
    }

    -- Convert to JSON
    local json_content = vim.fn.json_encode(complete_details)

    -- Write to file
    local file = io.open(filename, "w")
    if file then
        file:write(json_content)
        file:close()

        vim.notify("API details saved to: " .. filename, vim.log.levels.INFO)

        -- Open the file for editing
        vim.cmd("edit " .. vim.fn.fnameescape(filename))
    else
        vim.notify("Failed to save API details to file", vim.log.levels.ERROR)
    end
end

-- Setup function
function M.setup(user_config)
    -- Merge user config with defaults
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

    -- Load commit rules
    if not M.load_rules() then
        vim.notify(
            "AI Commit plugin loaded with warnings - commit rules not loaded",
            vim.log.levels.WARN)
    end

    -- Set up keymaps
    local map = vim.keymap.set
    local keymaps = M.config.keymaps

    map("n", keymaps.generate, function() M.generate_ai_message() end,
        {desc = "Generate AI commit message"})
end

return M
