PUBLIC_URL=https://${domain}
LOG_LEVEL=trace
CONFIG=~/.jitsi-meet-cfg
HTTP_PORT=8000
HTTPS_PORT=8443
TZ=UTC
ETHERPAD_TITLE="Alve"
ETHERPAD_DEFAULT_PAD_TEXT="Welcome to Alve!\n\n"
ETHERPAD_SKIN_NAME=colibris
ETHERPAD_SKIN_VARIANTS="super-light-toolbar super-light-editor light-background full-width-editor"

# Frontend (web service)
DEPLOYMENTINFO_ENVIRONMENT=production
DEPLOYMENTINFO_ENVIRONMENT_TYPE=cloud
DEPLOYMENTINFO_REGION=${region}
DEPLOYMENTINFO_SHARD=${shard}
DEPLOYMENTINFO_USERREGION=${region}

# Prosody
ENABLE_OCTO=true
ENABLE_AUTH=true
ENABLE_LETSENCRYPT=true
LETSENCRYPT_DOMAIN=${domain}
LETSENCRYPT_EMAIL=${email}

# XMPP server (prosody service)
ENABLE_S2S=true
XMPP_DOMAIN=${xmpp_domain}
XMPP_AUTH_DOMAIN=auth.${xmpp_domain}
XMPP_GUEST_DOMAIN=guest.${xmpp_domain}
XMPP_MUC_DOMAIN=muc.${xmpp_domain}
XMPP_INTERNAL_MUC_DOMAIN=internal-muc.${xmpp_domain}
JWT_APP_ID=alve-jitsi
JWT_APP_SECRET=${jwt_app_secret}
JWT_ALLOW_EMPTY=false

# Focus component (jicofo service)
JICOFO_OCTO_REGION=${region}
JICOFO_AUTH_PASSWORD=${jicofo_auth_password}
ENABLE_VISITORS=false

# Video Bridge (jvb service)
ENABLE_COLIBRI_WEBSOCKET=false
JVB_XMPP_SERVER=${xmpp_domain}
JVB_AUTH_PASSWORD=${jvb_auth_password}

# Secrets
JICOFO_COMPONENT_SECRET=${jicofo_component_secret}
