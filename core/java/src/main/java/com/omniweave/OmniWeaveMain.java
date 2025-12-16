/*
 * Copyright © 2025, Devin B. Royal.
 * All Rights Reserved.
 */

package com.omniweave;

import java.time.Instant;
import java.util.Objects;

public final class OmniWeaveMain {

    public static void main(String[] args) {
        try {
            String mode = (args != null && args.length > 0) ? args[0] : "status";
            System.out.println("[OmniWeave] Java core online @ " + Instant.now());
            System.out.println("[OmniWeave] mode=" + mode);
            // Future: bind governance, adapters, and audit chain from manifests/
            if (!Objects.equals(mode, "status") && !Objects.equals(mode, "demo")) {
                System.out.println("[OmniWeave] Unknown mode, falling back to status.");
            }
        } catch (Throwable t) {
            System.err.println("[OmniWeave] Fatal error: " + t.getMessage());
            t.printStackTrace(System.err);
            System.exit(1);
        }
    }
}

/*
 * Copyright © 2025, Devin B. Royal.
 * All Rights Reserved.
 */