if ip route | grep -q 147.75.0.0/16; then
	echo "%{u#00ff00}  "
else
	echo "%{u#ff0000}  "
fi
