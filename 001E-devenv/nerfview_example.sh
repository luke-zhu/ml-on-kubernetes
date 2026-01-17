#!/bin/bash
# Download example data
ns-download-data nerfstudio --capture-name=poster

# Train with viewer enabled
ns-train nerfacto \
  --data data/nerfstudio/poster \
  --viewer.start-train true \
  --viewer.websocket-port 7007 \
  --max-num-iterations 5000

# Or train first, then view
# ns-train nerfacto --data data/nerfstudio/poster
# ns-viewer --load-config outputs/poster-nerfacto-*/config.yml
