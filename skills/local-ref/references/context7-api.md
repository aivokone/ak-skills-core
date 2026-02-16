# Context7 API Reference

Two approaches for accessing Context7. Use whichever is available.

## Option A: MCP Tools (if Context7 plugin is enabled)

```
Tool: resolve-library-id
  libraryName: "react"
  query: "hooks state management"

Tool: query-docs
  libraryId: "/websites/react_dev_reference"
  query: "useState hook usage and examples"
```

## Option B: curl (if MCP not available, or from a skill)

### Search for library ID

```bash
curl -s "https://context7.com/api/v2/libs/search?libraryName=LIBRARY&query=TOPIC" | jq '.results[0]'
```

Response fields: `id`, `title`, `description`, `totalSnippets`

### Fetch documentation

```bash
curl -s "https://context7.com/api/v2/context?libraryId=LIBRARY_ID&query=TOPIC&type=txt"
```

Parameters:
- `libraryId` (required): from search results (e.g., `/vitejs/vite`)
- `query` (required): specific topic (e.g., `build manifest plugin configuration`)
- `type` (optional): `json` (default) or `txt` (more readable)

### Tips

- URL-encode multi-word queries (`+` or `%20` for spaces)
- No API key required for basic usage (rate-limited)
- `type=txt` produces more readable output for saving to local docs
- Use `jq` to filter JSON responses

### Common library IDs

| Technology | Library ID |
|---|---|
| WordPress Functions | `/websites/developer_wordpress_reference_functions` |
| WordPress Classes | `/websites/developer_wordpress_reference_classes` |
| ACF Pro | `/wordpress-premium/advanced-custom-fields-pro` |
| Vite | `/vitejs/vite` |
| React | `/websites/react_dev_reference` |
| Next.js | `/vercel/next.js` |
| Bootstrap | `/twbs/bootstrap` |
| Tailwind CSS | `/tailwindlabs/tailwindcss` |
| Laravel | `/laravel/docs` |
| Roots/Sage/Bedrock | `/roots/docs` |
