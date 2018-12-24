[Service]
Type=oneshot
ExecStart=/usr/bin/sh ${base_path}/bootstrap.sh

[Install]
WantedBy=multi-user.target
