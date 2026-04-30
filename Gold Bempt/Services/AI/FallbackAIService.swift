import Foundation

// Keyword-driven deterministic fallback used when Foundation Models are unavailable
// or when the free-tier session limit is reached.

final class FallbackAIService: AIServiceProtocol {

    var isAvailable: Bool { true }

    func respond(to question: String, context: String) async throws -> String {
        let q = question.lowercased()
        return Self.match(query: q, context: context)
    }

    // MARK: - Keyword Matching

    private static func match(query: String, context: String) -> String {
        for (keywords, response) in knowledgeBase {
            if keywords.contains(where: { query.localizedStandardContains($0) }) {
                return response
            }
        }
        return generic(for: context)
    }

    private static func generic(for context: String) -> String {
        if !context.isEmpty {
            return "This relates to: \(context). The Gold Rush (1848–1855) was a period of rapid migration and economic transformation in California. Hundreds of thousands of prospectors flooded the Sierra Nevada foothills hoping to strike it rich — most did not, but the era reshaped America permanently."
        }
        return "The California Gold Rush began on January 24, 1848, when James Marshall discovered gold at Sutter's Mill in Coloma, California. The news spread rapidly, drawing over 300,000 migrants from across the world between 1848 and 1855, forever changing the American West."
    }

    // MARK: - Knowledge Base

    private static let knowledgeBase: [([String], String)] = [
        (
            ["start", "begin", "when", "1848", "discovery"],
            "The California Gold Rush began on January 24, 1848, when carpenter James W. Marshall discovered flakes of gold in the American River at Sutter's Mill in Coloma, California. Word spread to San Francisco by May, and by 1849 — giving '49ers their name — gold-seekers were pouring in from every corner of the globe."
        ),
        (
            ["james marshall", "marshall"],
            "James W. Marshall (1810–1885) was a carpenter working for John Sutter when he spotted gold flakes in the millrace of Sutter's sawmill on January 24, 1848. Despite being the man who triggered one of history's greatest migrations, Marshall died in poverty in 1885, having never profited significantly from his famous discovery."
        ),
        (
            ["john sutter", "sutter"],
            "John Sutter (1803–1880) owned the land where gold was discovered. Rather than making him rich, the rush destroyed his agricultural empire — prospectors overran his property, squatters claimed his land, and his cattle were slaughtered. He spent years in Washington seeking compensation from Congress but died bankrupt and bitter."
        ),
        (
            ["miner", "prospector", "life", "daily", "camp"],
            "Daily life for miners was brutal and unglamorous. Men slept in crude tents or dugouts, ate beans and salt pork, labored 12–16 hours a day in icy rivers or cramped shafts, and faced disease, injury, and isolation constantly. The average '49er made little more than a laborer back East — the real fortunes went to merchants, not miners."
        ),
        (
            ["levi strauss", "denim", "jeans", "pants"],
            "Levi Strauss arrived in San Francisco in 1853 as a dry-goods merchant. In 1873, partnering with tailor Jacob Davis, he patented riveted denim work pants — the ancestor of modern blue jeans. The durability miners needed created a brand still iconic 150 years later. Strauss became one of the Rush's most enduring commercial success stories."
        ),
        (
            ["rich", "millionaire", "fortune", "wealthy", "money"],
            "The Gold Rush minted very few miner millionaires. The people who genuinely got rich were suppliers, merchants, and entrepreneurs: Sam Brannan (who bought up shovels and pans before announcing the gold discovery), Levi Strauss (clothing), Mark Hopkins and Collis Huntington (hardware), and the 'Big Four' who later built the Central Pacific Railroad. For most miners, the dream never materialized."
        ),
        (
            ["sam brannan", "brannan"],
            "Sam Brannan (1819–1889) became California's first millionaire not by mining but by announcing the gold rush. Before public word spread, he quietly bought every pick, shovel, and pan in San Francisco, then ran through the streets shouting about the discovery. He sold his supplies at enormous mark-ups. A canny self-promoter, he later lost his fortune to alcoholism and a costly divorce."
        ),
        (
            ["chinese", "asian", "immigrant", "foreign"],
            "An estimated 25,000 Chinese immigrants arrived during the Gold Rush, facing intense discrimination. California's Foreign Miners' Tax (1850) targeted them specifically. Despite being pushed to tailings already worked by white miners, Chinese communities built thriving settlements, contributed enormously to building the transcontinental railroad, and founded what became San Francisco's Chinatown."
        ),
        (
            ["woman", "women", "female", "gender"],
            "Women were scarce in the mining camps — fewer than 8% of California's gold-rush population was female. Those who did arrive often worked as cooks, laundresses, or boardinghouse keepers, frequently earning more than the men panning for gold. A small number of women disguised themselves as men to work the mines. Others, like Mary Ellen Pleasant, built business empires."
        ),
        (
            ["environment", "pollution", "river", "hydraulic", "damage"],
            "Hydraulic mining — blasting hillsides with high-pressure water — devastated California's rivers and valleys. Billions of tons of sediment smothered farmland downstream. By the 1880s, farmers won a landmark legal case banning hydraulic mining, one of America's earliest environmental protection victories. The scars are still visible in parts of the Sierra Nevada today."
        ),
        (
            ["san francisco", "city", "population", "growth"],
            "San Francisco transformed almost overnight. Its population exploded from roughly 1,000 in 1848 to over 25,000 by 1850, and topped 50,000 by 1860. The city became the financial and commercial capital of the West, with banks, newspapers, luxury hotels, and theaters catering to a restless, transient population flush with gold-rush money — or dreams of it."
        ),
        (
            ["california", "state", "statehood", "union"],
            "The Gold Rush accelerated California's path to statehood dramatically. The sudden surge in population — bypassing the usual territorial phase — meant California applied for statehood only two years after the Mexican-American War ceded the land to the U.S. On September 9, 1850, California was admitted as a free state, intensifying the national debate over slavery."
        ),
        (
            ["disease", "death", "cholera", "mortality"],
            "Disease killed far more miners than accidents. Cholera swept the overland trails. In the camps, scurvy from poor diet, typhoid from contaminated water, and dysentery were constant killers. The journey itself — whether by ship around Cape Horn or overland across the Rockies — claimed thousands of lives before anyone reached California."
        ),
        (
            ["route", "trail", "travel", "journey", "ship", "cape horn", "panama"],
            "Gold-seekers had three main routes to California. The overland trail (2,000 miles across the continent) took 4–6 months and risked starvation, disease, and attack. The sea route around Cape Horn took 5–8 months but was safer. The Panama route — crossing the isthmus by land then sailing north — cut the journey to 5–8 weeks but exposed travelers to tropical disease."
        ),
        (
            ["end", "bust", "decline", "finish", "over"],
            "The surface gold ran out fast. By 1852, most placer gold accessible to individual miners was gone. Industrial mining companies moved in with expensive equipment, driving individual prospectors away. Many returned home broke; others scattered to new rushes in Nevada, Colorado, and Australia. The California Rush is conventionally dated 1848–1855, though mining continued industrially for decades after."
        ),
    ]
}
