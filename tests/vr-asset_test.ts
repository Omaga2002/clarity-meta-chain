import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can mint VR asset",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const assetProps = {
      name: "Test Asset",
      description: "Test Description",
      uri: "ipfs://test",
      properties: [{key: "test", value: "value"}]
    };
    
    let block = chain.mineBlock([
      Tx.contractCall('vr-asset', 'mint', [
        types.uint(1),
        types.utf8(assetProps.name),
        types.utf8(assetProps.description),
        types.utf8(assetProps.uri),
        types.list(assetProps.properties)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});
