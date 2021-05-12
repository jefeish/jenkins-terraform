# jenkins-terraform

Repo to create a Jenkins AWS instance (no docker)

## Deploy

### Init

Prepare the required resource (create the `.terraform` folder)

```bash
terraform init
```

---

### Validate

Check if the `terraform plan` is valid

```bash
terraform validate
```

> Note: `plan` also does a `validate`, so you might skip this step.
---

### Plan

Prepare / review what resources the `terraform plan` would apply

```bash
terraform plan
```

---

### Apply

Apply the `terraform plan`, create the resources

```bash
terraform apply
```

## Secure Jenkins

This is still a semi manual process. Terraform installs all required tools but the actual installation is described in the `Secure Nginx Connection` section :point_down: (see *References*).

---

## References

### Secure Nginx Connection

- [How to Secure Nginx with Let's Encrypt](https://phoenixnap.com/kb/letsencrypt-nginx) - This uses a Nginx plugin to automatically update the Nginx virtual host configuration.

    :warning: Make sure to set the right Nginx `proxy` settings *(this needs to be modified from the Nginx plugin genereated config)*

    ```bash
    proxy_redirect  http://localhost:8080 https://<your_domain>.com;
    proxy_pass      http://localhost:8080;
    ```

    > replace `<your_domain>`

- [How to Configure Jenkins with SSL using an Nginx Reverse Proxy](https://www.digitalocean.com/community/tutorials/how-to-configure-jenkins-with-ssl-using-an-nginx-reverse-proxy) - Disable the Jenkins '8080' access when HTTPS is enabled.
