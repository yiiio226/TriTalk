# TriTalk Cost Analysis

[中文](cost_analysis.md) | **English**

> 📊 This document provides a detailed analysis of the operational costs for TriTalk's various service components to help evaluate and optimize project expenses.

---

## 📊 Comprehensive Cost Summary

> 💡 **Quick Overview**: Estimated monthly total cost and cost per user based on DAU scale.

| DAU Scale | Cloudflare | Supabase | GCP TTS         | Azure Speech | **Monthly Total Cost** | **Cost Per User/Mo** |
| --------- | ---------- | -------- | --------------- | ------------ | ---------------------- | -------------------- |
| Dev Phase | $0         | $0       | $0 (Free Tier)  | $0 (Testing) | **$0**                 | -                    |
| 100 DAU   | $0         | $0       | $0 (Free Tier)  | ~$165        | **~$165/Mo**           | **~$1.65**           |
| 1000 DAU  | $5         | $0-25    | $750-1,500\*    | $1,650       | **$2,400-3,200/Mo**    | **$2.4-3.2**         |
| 10K DAU   | $11        | $25      | $7,500-15,000\* | $16,500      | **$24,000-31,500/Mo**  | **$2.4-3.15**        |

> \* TTS cost assumes a 50% cache hit rate; actual costs can be further reduced through optimized caching strategies.
>
> 📉 **Economies of Scale**: As the user base grows, the cost per user stabilizes at **$2.4-3.2/month**, primarily driven by AI services (TTS + Pronunciation Assessment).

---

## 📋 Service Overview

TriTalk adopts a modern serverless architecture, primarily utilizing the following cloud services:

| Service           | Purpose                          | Status          |
| ----------------- | -------------------------------- | --------------- |
| Cloudflare Worker | Edge Computing, AI Gateway/Proxy | ✅ In Use       |
| Cloudflare R2     | Object Storage                   | ⏸️ Not Used Yet |
| Supabase          | Database + Auth                  | ✅ In Use       |
| GCP Vertex AI     | Gemini TTS Synthesis             | ✅ In Use       |
| Azure Speech      | Pronunciation Assessment         | ✅ In Use       |

---

## 💰 Detailed Service Costs

### 1. Cloudflare Worker

> Edge function runtime environment, handling AI request proxying, prompt engineering, etc.

#### Pricing Model

| Plan | Request Volume           | Cost                |
| ---- | ------------------------ | ------------------- |
| Free | 100,000 requests/day     | **$0**              |
| Paid | First 10M requests/month | Starts at **$5/Mo** |
| Paid | Excess usage             | $0.30 / 1M requests |

#### Cost Estimation

| Scenario         | Assumption                      | Cost       |
| ---------------- | ------------------------------- | ---------- |
| 1000 DAU (Light) | 50 reqs/user/day = 1.5M reqs/mo | **$5/Mo**  |
| 1000 DAU (Heavy) | 200 reqs/user/day = 6M reqs/mo  | **$5/Mo**  |
| 10,000 DAU       | 100 reqs/user/day = 30M reqs/mo | **$11/Mo** |

> 💡 **Conclusion**: Cloudflare Worker costs are extremely low, only about $11/month even at 10K DAU.

---

### 2. Cloudflare R2 Storage

> Object storage, can be used for storing audio files, user resources, etc.

#### Pricing Model

| Resource    | Free Allowance        | Excess Cost      |
| ----------- | --------------------- | ---------------- |
| Storage     | 10 GB / month         | $0.015 / GB / Mo |
| Class A Ops | 1M ops / month        | $4.50 / 1M ops   |
| Class B Ops | 10M ops / month       | $0.36 / 1M ops   |
| Egress      | Free (No egress fees) | **$0**           |

#### Current Status

⏸️ **Not Used Yet** - Currently, audio is cached locally on the client, so R2 storage is not required.

#### Future Estimation (If Enabled)

| Scenario   | Assumption               | Cost                         |
| ---------- | ------------------------ | ---------------------------- |
| 1000 DAU   | 5GB Storage + 500k reads | **$0/Mo** (Within Free Tier) |
| 10,000 DAU | 50GB Storage + 5M reads  | **~$1/Mo**                   |

> 💡 **Conclusion**: R2 is almost free and suitable for future expansion.

---

### 3. Supabase

> PostgreSQL Database + Auth Service + Realtime Subscriptions

#### Pricing Model

| Plan | Database  | Storage   | Bandwidth | Cost        |
| ---- | --------- | --------- | --------- | ----------- |
| Free | 500 MB    | 1 GB      | 2 GB      | **$0**      |
| Pro  | 8 GB      | 100 GB    | 250 GB    | **$25/Mo**  |
| Team | Unlimited | Unlimited | Unlimited | **$599/Mo** |

#### Free Plan Limits

| Resource            | Limit        |
| ------------------- | ------------ |
| Database Size       | 500 MB       |
| File Storage        | 1 GB         |
| Bandwidth           | 2 GB / Month |
| Edge Function Calls | 500k / Month |
| MAU (Auth)          | Unlimited    |

#### Cost Estimation

| Scenario       | Estimated DB Size | Recommended Plan | Cost         |
| -------------- | ----------------- | ---------------- | ------------ |
| Dev/Test Phase | < 100 MB          | Free             | **$0/Mo**    |
| 1000 DAU       | ~200 MB           | Free / Pro       | **$0-25/Mo** |
| 10,000 DAU     | ~1-2 GB           | Pro              | **$25/Mo**   |

> 💡 **Conclusion**: The Free plan suffices for early stages; upgrade to Pro ($25/Mo) as users grow.

---

### 4. GCP Vertex AI - Gemini TTS

> Uses Gemini 2.5 Flash Preview TTS for speech synthesis.

#### Pricing Model

| Item   | Free Tier      | Paid Tier          |
| ------ | -------------- | ------------------ |
| Input  | Free of charge | $0.50 / 1M tokens  |
| Output | Free of charge | $10.00 / 1M tokens |

#### Token Billing Rules (Official)

- **Input**: $0.50 / 1M text tokens
- **Output**: $10.00 / 1M **audio tokens**
- **Conversion**: **1 second audio = 25 tokens**
- **Unit Price**: Approx **$0.015 / minute** ($0.90 / hour)

#### Cost Estimation

##### Dialogue/Shadowing Scenario (Long Sentence TTS)

| Scenario                        | Assumption                      | Calculation                     | Cost                     |
| ------------------------------- | ------------------------------- | ------------------------------- | ------------------------ |
| Single Sentence TTS (~10 words) | Speed ~150 wpm → ~**4 sec**     | 4s × 25 tokens = **100 tokens** | **$0.001**               |
| User Daily (50 sentences)       | 50 sents × 4s = 200s (~3.3 min) | 50 × $0.001                     | **$0.05 / Day**          |
| **1000 DAU / Mo (No Cache)**    | 1000 users × 30 days            | 1000 × 30 × $0.05               | **$1,500/Mo (≈¥10,800)** |
| 1000 DAU / Mo (50% Cache)       | 50% Cache Hit Rate              | $1,500 × 50%                    | **$750/Mo (≈¥5,400)**    |

##### Word Pronunciation Scenario (Short Word TTS)

| Scenario                  | Calculation (Est.)   | Cost                  |
| ------------------------- | -------------------- | --------------------- |
| Single Word TTS (est. 1s) | 25 tokens × $0.00001 | **$0.00025**          |
| User Daily (100 words)    | 100 × $0.00025       | **$0.025 / Day**      |
| 1000 DAU / Mo (No Cache)  | 1000 × 30 × $0.025   | **$750/Mo (≈¥5,400)** |
| 1000 DAU / Mo (90% Cache) | $750 × 10%           | **$75/Mo (≈¥540)**    |

> 💡 **Current Advantages**:
>
> - ✅ Preview model has **Free Tier** quota
> - ✅ Have **$25,000 GCP Credits**, covering operational costs for a significant period
> - ✅ Due to the **25 tokens/sec** low consumption rate, costs are much lower than traditional character-based billing models

---

### 5. Azure Speech - Pronunciation Assessment

> Uses Azure Speech Service for Pronunciation Assessment.

#### Pricing Model

| Service Type              | Billing Method    | Price         |
| ------------------------- | ----------------- | ------------- |
| Speech-to-Text (Realtime) | Per second        | **$1 / Hour** |
| Pronunciation Assessment  | Included in above | No extra cost |

> 💡 **Billing Note**: Features like phoneme-level scoring and prosody analysis are value-added features of STT pricing, with no additional charges.

#### Cost Estimation

| Scenario                         | Assumption                      | Calculation                   | Cost                     |
| -------------------------------- | ------------------------------- | ----------------------------- | ------------------------ |
| Single Sentence Eval (~10 words) | Speed ~150 wpm → ~**4 sec**     | 4s × ($1/3600s) = **$0.0011** | **$0.001**               |
| User Daily (50 sentences)        | 50 sents × 4s = 200s (~3.3 min) | 3.3min × $0.0167/min          | **$0.055 / Day**         |
| **1000 DAU / Mo (No Cache)**     | 1000 users × 30 days            | 1000 × 30 × $0.055            | **$1,650/Mo (≈¥11,880)** |

> 📊 **Comparative Analysis**: Azure Pronunciation Assessment costs are similar to GCP Gemini TTS (both around $1,500-1,700/Mo @ 1000 DAU), but provide professional pronunciation diagnosis capabilities (phoneme-level scoring, prosody analysis, fluency detection, etc.).

---

### Cost Optimization Strategies

| Strategy                      | Affected Service | Est. Savings         |
| ----------------------------- | ---------------- | -------------------- |
| **TTS Audio Caching**         | GCP TTS          | 50-90%               |
| **Local TTS Fallback**        | GCP TTS          | 20-40%               |
| **Assessment Result Caching** | Azure Speech     | 30-50%               |
| **Batch Request Merging**     | All              | 10-20%               |
| **GCP $25K Credits**          | GCP TTS          | Covers initial costs |

---

## 🎯 Cost Control Recommendations

### Short-term (0-1000 DAU)

1. ✅ Fully utilize the **Free Tier** of each service
2. ✅ Use GCP **$25,000 Credits** to cover TTS costs
3. ✅ Implement efficient **Client-side Caching Strategies** to reduce repeated API calls

### Mid-term (1000-10000 DAU)

1. ⚙️ Optimize cache hit rate to **80%+**
2. ⚙️ Evaluate introducing a **CDN Caching Layer** (Cloudflare R2)
3. ⚙️ Consider **Reserved Capacity** for better pricing

### Long-term (10000+ DAU)

1. 📈 Negotiate **Enterprise Discounts** with cloud providers
2. 📈 Evaluate feasibility of **Self-hosted Speech Services**
3. 📈 Implement **Tiered Pricing Strategies** (Free/Paid users)

---

## 📚 Related Documents

- [GCP TTS Implementation Guide](../backend/docs/gcp_tts.md)
- [Word Pronunciation Playback Scheme](../backend/docs/word_pronunciation.md)
- [Azure Speech Pronunciation Assessment Design](../backend/docs/azure_speech.md)
- [Cache Strategy Document](../frontend/doc/cache_strategy.md)

---

## 📝 Change Log

| Date       | Update Content                                                |
| ---------- | ------------------------------------------------------------- |
| 2026-01-19 | Initial version: Integrated cost analysis of various services |
