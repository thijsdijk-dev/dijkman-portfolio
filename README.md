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

### Automatisch dagelijks via cron

Open je crontab:

```bash
crontab -e
```

En voeg bijvoorbeeld toe (elke nacht 03:30):

```cron
30 3 * * * cd /workspace/dijkman-portfolio && USB_MOUNT=/mnt/usb16 npm run backup:usb >> /var/log/dijkman-backup.log 2>&1
```

## Opmerking

Als `dist` of `docker-compose.yml` (nog) niet bestaan, slaat het script die onderdelen over en gaat het gewoon verder.
