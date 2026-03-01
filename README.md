# dijkman-portfolio

Portfolio website gebouwd met Astro.

## Ontwikkeling

| Command | Beschrijving |
| --- | --- |
| `npm install` | Installeert dependencies |
| `npm run dev` | Start lokale dev server (`localhost:4321`) |
| `npm run build` | Bouwt productie-output in `./dist` |
| `npm run preview` | Preview van de build |
| `npm run backup:usb` | Maakt backups naar een externe USB mount |
| `npm run backup:install-cron` | Stelt een automatische dagelijkse backup in via cron |

## USB backup op Raspberry Pi

Voor jouw scenario (NPM data + `dist` + `docker-compose.yml` naar externe storage) is er een script toegevoegd:

```bash
npm run backup:usb
```

Standaard verwacht het script dat je USB stick gemount is op:

```text
/media/pi/backup-usb
```

Backups komen dan in:

```text
/media/pi/backup-usb/dijkman-portfolio-backups
```

Per run worden aparte `.tar.gz` bestanden gemaakt voor:
- `~/.npm` (NPM data)
- `./dist`
- `./docker-compose.yml`

### Eigen paden instellen

Je kunt paden overschrijven met environment variables:

```bash
USB_MOUNT=/mnt/usb16 \
NPM_DATA_PATH=/home/pi/.npm \
DIST_PATH=/workspace/dijkman-portfolio/dist \
COMPOSE_FILE=/workspace/dijkman-portfolio/docker-compose.yml \
npm run backup:usb
```

## Automatische backups (cron)

Ja, backups kunnen automatisch draaien. Gebruik hiervoor:

```bash
USB_MOUNT=/mnt/usb16 npm run backup:install-cron
```

Dit installeert (of update) een cronregel die standaard elke nacht om **03:30** draait.

### Cron planning aanpassen

Standaard schema:

```text
30 3 * * *
```

Voorbeeld: elk uur draaien:

```bash
BACKUP_SCHEDULE='0 * * * *' USB_MOUNT=/mnt/usb16 npm run backup:install-cron
```

### Loglocatie aanpassen

```bash
LOG_FILE=/home/pi/backup.log USB_MOUNT=/mnt/usb16 npm run backup:install-cron
```

## Opmerking

Als `dist` of `docker-compose.yml` (nog) niet bestaan, slaat het backupscript die onderdelen over en gaat het gewoon verder.

## Snes9x: alleen Super Instinct toestaan

Voor de serverconfiguratie is de bedoeling dat alleen deze ROM aanwezig is:

```text
/retroarch/roms/superinstinct.sfc
```

Voorbeeld (op de server):

```bash
mkdir -p /retroarch/roms
cp /pad/naar/superinstinct.sfc /retroarch/roms/superinstinct.sfc
find /retroarch/roms -type f ! -name 'superinstinct.sfc' -delete
```

Daarmee verwijder je alle andere ROMs en kan alleen Super Instinct gestart worden via de launcher op `/retroarch/snes/`.

