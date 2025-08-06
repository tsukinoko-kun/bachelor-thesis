This software is a proof of concept for cloud gaming.

I need as little latency as possible. Reduce network hops and big bandwidth usage.

Project structure:

```
.
├── AGENTS.md
├── backend
│   ├── go.mod
│   ├── go.sum
│   ├── internal
│   │   ├── broadcaster
│   │   │   └── broadcaster.go
│   │   ├── gstreamer
│   │   │   ├── gstreamer_linux_nvidia.go
│   │   │   ├── gstreamer_mac.go
│   │   │   ├── gstreamer_win_nvidia.go
│   │   │   └── gstreamer.go
│   │   └── server
│   │       └── server.go
│   ├── main.go
│   └── tmp
│       └── main
├── frontend
│   ├── index.html
│   ├── node_modules
│   │   ├── typescript -> .pnpm/typescript@5.8.3/node_modules/typescript
│   │   └── vite -> .pnpm/vite@7.0.4/node_modules/vite
│   ├── package.json
│   ├── pnpm-lock.yaml
│   ├── public
│   ├── src
│   │   ├── main.ts
│   │   ├── style.css
│   │   └── vite-env.d.ts
│   └── tsconfig.json
└── justfile
```

Make sure you are in the correct directory when running any commands.

Frontend and backend are two separate applications. Don't mix them up!

## Backend

Use Go.

Wrap errors with `fmt.Errorf` using `%w` to add additional context to the error.

Use modern Go.
Use `any` instead of `interface{}`.
For loops copy the iterating variable, no need to copy them manually.
Don't use `ioutil` package, it is deprecated.

Run `go build ./...` and `go test ./...` before you claim to be finished.

## Frontend

This is a Vite project. `index.html` is the entry point.

Use PNPM. Use TypeScript.

Use `??` for nullish checks and `||` for falsy checks. They are not the same!

Use `const` if possible. Use `let` if you need to reassign a variable.

Use `"` for all strings unless there is a specific reason to use something else.

Always run `pnpm run build` before you before you claim to be finished.
