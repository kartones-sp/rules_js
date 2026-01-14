import { spawnSync } from 'node:child_process'

const [toolPath, packageDir, ...restArgs] = process.argv.slice(2)

const spawn = spawnSync(toolPath, ['publish', packageDir, ...restArgs], {
    stdio: 'inherit',
})

process.exit(spawn.status)
