
local M = {}
local utils = require("42norm.utils")

function M.format()
    -- Get the current buffer
    local buf = vim.api.nvim_get_current_buf()
    local filetype = utils.get_extension(buf)
    if filetype ~= "c" and filetype ~= "h" then
        return
    end

    -- Create a temporary file with the buffer content
    local temp_file, err = utils.create_temp_file(buf)
    if not temp_file then
        vim.notify("Failed to create temporary file: " .. err, vim.log.levels.ERROR)
        return
    end

    -- Run the formatter command on the temporary file
    local cmd = "c_formatter_42 " .. temp_file
    local output = vim.fn.system(cmd)

    -- Check exit code
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to format the code. Output:\n" .. output, vim.log.levels.ERROR)
        os.remove(temp_file)
        return
    end

    -- Read the formatted content
    local formatted_file = io.open(temp_file, "r")
    if not formatted_file then
        vim.notify("Failed to read the formatted file.", vim.log.levels.ERROR)
        os.remove(temp_file)
        return
    end

    local formatted_content = formatted_file:read("*a")
    formatted_file:close()

    -- Split content into lines and remove trailing empty line if any
    local lines = vim.split(formatted_content, "\n")
    if lines[#lines] == "" then
        table.remove(lines, #lines)
    end

    -- Replace buffer content with the formatted result
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Delete the temporary file
    os.remove(temp_file)
end

return M
